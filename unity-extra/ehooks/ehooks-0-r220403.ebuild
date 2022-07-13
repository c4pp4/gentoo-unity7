# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=

inherit ubuntu-versionator

DESCRIPTION="ehooks patching system"
HOMEPAGE="https://github.com/c4pp4/gentoo-unity7"
SRC_URI=""

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+fontconfig +libreoffice +terminal"
RESTRICT="binchecks strip test"

RDEPEND="fontconfig? ( media-libs/freetype:2[adobe-cff,cleartype-hinting,-infinality] )"
DEPEND="unity-base/unity-build-env"

S="${WORKDIR}"

pkg_setup() {
	ubuntu-versionator_pkg_setup
	[[ -f ${EROOT}/etc/ehooks/timestamps ]] && cp "${EROOT}"/etc/ehooks/timestamps "${S}"/timestamps.old

	## Temporarily: USE flags names migration ##
	sed -i \
		-e "s/_adjust//" \
		-e "s/_menu//" \
		-e "s/_theme//" \
		"${S}"/timestamps.old || die
}

src_install() {
	local \
		count=1 \
		sys_db="/var/db/pkg/" \
		timestamp=$(date "+%s") \
		pkg_flag sys_flag x m n change slot prev_shopt

	local -a \
		ehk=() pkg=() \
		indicator=( "|" "/" "-" "\\" )

	echo "## Automatically generated file: please don't remove or edit" > timestamps

	printf "%s" "Generating timestamps file ${indicator[0]}"
	for x in ${IUSE}; do
		x="${x#+}"

		## Progress indicator.
		[[ ${count} -eq 4 ]] && count=0
		printf "\b\b %s" "${indicator[${count}]}"
		count=$((count + 1))

		## Find out if there is USE flag change.
		use "${x}" && pkg_flag=1 || pkg_flag=0
		portageq has_version / unity-extra/ehooks["${x}"] && sys_flag=1 || sys_flag=0
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
			[[ ${m} == *":"+([0-9.]) ]] && slot=${m#*:} || slot=""
			m=${m%:*}

			## Skip if timestamp already exists.
			grep -Fq "${m}|${x}" timestamps && continue

			## Copy timestamp or create a new one.
			! grep -Fs "${m}|${x}" timestamps.old >> timestamps \
				&& echo "${m}|${x}|$(use ${x} && echo ${timestamp} || echo 0000000000)|0000000000" >> timestamps \
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
				[[ -z ${slot} ]] || grep -Fqsx "${slot}" "${n}/SLOT" || continue

				if use "${x}"; then
					[[ $(date -r "${n}" "+%s") -ge $(grep -F "${m}|${x}" timestamps | cut -d "|" -f 4) ]] \
						&& sed -i -e "/${m/\//\\/}|${x}/{s/|[0-9]\{10\}|/|${timestamp}|/}" timestamps
				else
					[[ $(date -r "${n}" "+%s") -ge $(grep -F "${m}|${x}" timestamps | cut -d "|" -f 3) ]] \
						&& sed -i -e "/${m/\//\\/}|${x}/{s/|[0-9]\{10\}$/|${timestamp}/}" timestamps
				fi
			done
		done
		unset change
	done
	printf "\b\b%s\n" "... done!"

	insinto /etc/ehooks
	doins timestamps

	dosym -r "${REPO_ROOT}"/ehooks_version_control.sh /usr/bin/ehooks
}

pkg_postinst() {
	ubuntu-versionator_pkg_postinst

	## Generate emerge command needed to apply ehooks changes.
	local \
		color_blink=$(tput blink) \
		color_norm=$(tput sgr0) \
		fn="get_subdirs get_repo_root get_ehooks_subdirs get_installed_packages get_slot find_flag_changes find_tree_changes ehooks_changes" \
		prev_shopt=$(shopt -p nullglob) \
		x="$(portageq get_repo_path / gentoo-unity7)"/ehooks_version_control.sh

	shopt -s nullglob
	local -a cfg_files=( "${EROOT}"/etc/ehooks/._cfg*timestamps )
	${prev_shopt}

	source <(awk "/^(${fn// /|})(\(\)|=\(\$)/ { p = 1 } p { print } /(^(}|\))|; })\$/ { p = 0 }" ${x} 2>/dev/null)
	cfg_files=( ${cfg_files[@]##*/} )
	[[ -n ${cfg_files[@]} ]] && source <(declare -f find_flag_changes | sed -e "/ts_file=/{s/timestamps/${cfg_files[-1]}/}")
	ehooks_changes

	for x in ${fn}; do
		unset ${x}
	done
}
