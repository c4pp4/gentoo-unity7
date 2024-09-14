# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=

inherit ubuntu-versionator

DESCRIPTION="Setup the Unity7 build environment and ehooks patching system"
HOMEPAGE="https://github.com/c4pp4/gentoo-unity7"
SRC_URI=""

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="amd64"
IUSE_EHOOKS="
	+fontconfig
	+libreoffice
"
IUSE="dev ${IUSE_EHOOKS}"
RESTRICT="binchecks strip test"

S="${WORKDIR}"

pkg_setup() {
	ubuntu-versionator_pkg_setup
	[[ -f ${EROOT}/etc/ehooks/timestamps ]] && cp "${EROOT}"/etc/ehooks/timestamps "${S}"/timestamps.old
	[[ -f ${EROOT}/etc/gentoo-unity7/timestamps ]] && cp "${EROOT}"/etc/gentoo-unity7/timestamps "${S}"/timestamps.old
}

src_install() {
	local \
		count=1 \
		sys_db="/var/db/pkg/" \
		timestamp=$(date "+%s") \
		pkg_flag sys_flag x m n change slot prev_shopt

	local -a \
		ehk=() pkg=()

	echo "## Automatically generated file: please don't remove or edit" > timestamps

	ebegin "Generating ${EROOT}/etc/gentoo-unity7/timestamps file"
	for x in ${IUSE_EHOOKS}; do
		x="${x#+}"

		## Find out if there is USE flag change.
		use "${x}" && pkg_flag=1 || pkg_flag=0
		"${PORTAGE_QUERY_TOOL}" has_version / unity-base/gentoo-unity-env["${x}"] && sys_flag=1 || sys_flag=0
		[[ ${pkg_flag} -eq ${sys_flag} ]] || change="yes"

		## Get ehooks containing USE flag.
		prev_shopt=$(shopt -p nullglob)
		shopt -s nullglob
		ehk=( $(grep -El "ehooks_(use|require) ${x}" "${REPO_ROOT}"/profiles/ehooks/*/*/*.ehooks) )
		${prev_shopt}

		for m in "${ehk[@]}"; do
			## Get ${CATEGORY}/{${P}-${PR},${P},${P%.*},${P%.*.*},${PN}} from ehooks' path.
			m=${m%/*.ehooks}
			m=${m#*/ehooks/}

			## Get ${SLOT}.
			[[ ${m} == *":"* ]] && slot=${m#*:} || slot=""
			m=${m%:*}

			## Skip if timestamp already exists.
			grep -Fq "${m}${slot:+:${slot}}|${x}" timestamps && continue

			## Copy timestamp or create a new one.
			! grep -Fs "${m}${slot:+:${slot}}|${x}" timestamps.old >> timestamps \
				&& echo "${m}${slot:+:${slot}}|${x}|$(use ${x} && echo ${timestamp} || echo 0000000000)|0000000000" >> timestamps \
				&& continue

			## Skip if there is no USE flag change.
			[[ -z ${change} ]] && continue

			## Get installed packages affected by the ehooks.
			prev_shopt=$(shopt -p nullglob) ## don't use extglob
			shopt -s nullglob
			[[ -d ${sys_db}${m} ]] && pkg=( "${sys_db}${m}" ) || pkg=( "${sys_db}${m}"{-[0-9],.[0-9],-r[0-9]}*/ )
			${prev_shopt}

			for n in "${pkg[@]}"; do
				## Try another package if slots differ.
				grep -Fqsx "${slot:-0}" "${n}/SLOT" || grep -qs "^${slot:-0}/" "${n}/SLOT" || continue

				if use "${x}"; then
					[[ $(date -r "${n}" "+%s") -ge $(grep -F "${m}${slot:+:${slot}}|${x}" timestamps | cut -d "|" -f 4) ]] \
						&& sed -i -e "/${m/\//\\/}${slot:+:${slot}}|${x}/{s/|[0-9]\{10\}|/|${timestamp}|/}" timestamps
				else
					[[ $(date -r "${n}" "+%s") -ge $(grep -F "${m}${slot:+:${slot}}|${x}" timestamps | cut -d "|" -f 3) ]] \
						&& sed -i -e "/${m/\//\\/}${slot:+:${slot}}|${x}/{s/|[0-9]\{10\}$/|${timestamp}/}" timestamps
				fi
			done
		done
		unset change
	done
	eend "0"

	n="gentoo-unity7"
	insinto /etc/"${n}"
	doins timestamps

	dosym -r "${REPO_ROOT}"/version_control.sh /usr/bin/gentoo-unity-ver

	for x in {accept_keywords,env,mask,unmask,use}; do
		dodir "/etc/portage/package.${x}"
		dosym -r "${REPO_ROOT}/profiles/${n}.${x}" \
			"/etc/portage/package.${x}/0000_${n}.${x}" || die
	done

	dodir "/etc/portage/env"
	dosym -r "${REPO_ROOT}/profiles/${n}.conf.env" \
		"/etc/portage/env/${n}.conf" || die

	use dev && dosym -r "${REPO_ROOT}/profiles/${n}-dev.accept_keywords" \
		"/etc/portage/package.accept_keywords/0001_${n}-dev.accept_keywords"
}

pkg_postinst() {
	ubuntu-versionator_pkg_postinst

	## Generate emerge command needed to apply ehooks changes.
	local \
		color_blink=$(tput blink) \
		color_norm=$(tput sgr0) \
		fn="einfo ewarn get_subdirs get_repo_root get_ehooks_subdirs get_installed_packages get_slot find_flag_changes find_tree_changes ehooks_changes" \
		prev_shopt=$(shopt -p nullglob) \
		x=$("${PORTAGE_QUERY_TOOL}" get_repo_path / gentoo-unity7)/version_control.sh

	shopt -s nullglob
	local -a cfg_files=( "${EROOT}"/etc/gentoo-unity7/._cfg*timestamps )
	${prev_shopt}

	source <(awk "/^(${fn// /|})(\(\)|=\(\$)/ { p = 1 } p { print } /(^(}|\))|; })\$/ { p = 0 }" "${x}" 2>/dev/null)
	cfg_files=( ${cfg_files[@]##*/} )
	[[ -n ${cfg_files[@]} ]] && source <(declare -f find_flag_changes | sed -e "/ts_file=/{s/timestamps/${cfg_files[-1]}/}")
	for x in get_repo_root find_flag_changes find_tree_changes; do
		source <(declare -f "${x}" | sed 's:portageq:"${PORTAGE_QUERY_TOOL}":')
	done

	if use dev; then
		echo
		ewarn "Overlay development packages unmasked. Continue if you really know how broken development packages could be."
	fi
	echo

	printf "%s" ">>> "
	ehooks_changes

	for x in ${fn}; do
		unset ${x}
	done
}
