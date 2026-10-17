#!/bin/bash

## Ubuntu releases to compare with.
stable_release="stonking"
dev_release=""
releases=( ${stable_release} ${dev_release} )

## Ubuntu archive components to look for source packages in.
components=(
	main
	universe
)

## Don't check these packages.
declare -A skip_packages=(
	["app-eselect/eselect-lightdm"]=
	["dev-java/jayatana"]=
	["unity-base/gentoo-unity-env"]=
	["unity-base/ubuntu-docs"]=
	["unity-base/unity-language-pack"]=
	["unity-base/unity-meta"]=
	["unity-base/unity-settings"]=
	["unity-extra/indicator-netspeed"]=
	["unity-extra/indicator-privacy"]=
	["unity-indicators/unity-indicators-meta"]=
	["unity-lens/unity-lens-meta"]=
	["unity-lens/unity-scope-extras"]=
	["x11-plugins/mailnag-messagingmenu-plugin"]=
)

## Packages with a different Ubuntu source package name.
declare -A upstream_names=(
	["dev-python/zombie-imp"]="python-zombie-imp"
	["gnome-extra/nemo-engrampa"]="nemo-fileroller"
	["unity-extra/indicator-classicmenu"]="classicmenu-indicator"
	["unity-extra/indicator-psensor"]="psensor"
	["unity-indicators/indicator-appearance"]="unity-indicator-appearance"
)

## Temporarily accept keywords from testing branch.
testing_packages=(
	mail-client/thunderbird:0/esr
	mail-client/thunderbird:0/stable
	www-client/firefox:esr
	www-client/firefox:rapid
)

## Packages with the major version (without slot).
major_version_packages=(
	mail-client/thunderbird
	sys-devel/gcc
	www-client/firefox
)

color_blink=$(tput blink 2>/dev/null)
color_blue=$(tput bold 2>/dev/null; tput setaf 4 2>/dev/null)
color_bold=$(tput bold 2>/dev/null)
color_cyan=$(tput setaf 6 2>/dev/null)
color_green=$(tput bold 2>/dev/null; tput setaf 2 2>/dev/null)
color_norm=$(tput sgr0 2>/dev/null)
color_red=$(tput bold 2>/dev/null; tput setaf 1 2>/dev/null)
color_underline=$(tput smul 2>/dev/null)
color_underline_end=$(tput rmul 2>/dev/null)
color_yellow=$(tput bold 2>/dev/null; tput setaf 3 2>/dev/null)

spinner=( "|" "/" "-" "\\" )
spinner_pos=1

## Downloaded Ubuntu Sources files.
sources_cache="${XDG_CACHE_HOME:-${HOME}/.cache}/gentoo-unity7"

## Path to the installed gentoo-unity7 repository (already set in the ebuild environment by profile.bashrc).
REPO_ROOT=${REPO_ROOT:-$(portageq get_repo_path / gentoo-unity7)}

einfo() {
	echo " ${color_green}*${color_norm} $*"
}

ewarn() {
	echo " ${color_yellow}*${color_norm} $*"
}

eerror() {
	echo " ${color_red}*${color_norm} $*"
}

## Advance the progress spinner.
spinner_step() {
	printf "\b\b %s" "${spinner[spinner_pos]}"
	spinner_pos=$(( (spinner_pos + 1) % ${#spinner[@]} ))
}

## Exit if a required tool ($1) from a package ($2) is not installed.
require_tool() {
	if [[ -z $(type -P "$1") ]]; then
		echo
		eerror "'$1' tool from '$2' package not found!"
		echo
		exit 1
	fi
}

## Print the development repository path: $1 or the current directory.
get_dev_repo() {
	local repo_path="${1:-${PWD}}"

	if [[ $(realpath -m "${repo_path}") == $(realpath -m "${REPO_ROOT}") ]]; then
		{ echo; eerror "Don't run it inside the installed repository! Run it inside the development repository or set its path."; echo; } >&2
		return 1
	fi

	if ! grep -Fqsx "gentoo-unity7" "${repo_path}"/profiles/repo_name; then
		{ echo; eerror "Development repository not found! Run it inside the development repository or set its path."; echo; } >&2
		return 1
	fi

	echo "${repo_path%/}"
}

## Print paths matching an ehooks glob pattern ($1: repository path prefix, $2: pattern relative to ehooks/).
ehooks_glob() {
	local prev_shopt=$(shopt -p nullglob)
	shopt -s nullglob
	local -a result=( "$1"ehooks/$2 )
	${prev_shopt}

	echo "${result[@]}"
}

## Print installed package directories matching ${CATEGORY}/{${P}-${PR},${P},${P%.*},${P%.*.*},${PN}}.
get_installed_packages() {
	local \
		prev_shopt=$(shopt -p nullglob) \
		vdb="/var/db/pkg"

	local -a result

	shopt -s nullglob ## don't use extglob
	[[ -d ${vdb}/$1 ]] && result=( "${vdb}/$1" ) || result=( "${vdb}/$1"{-[0-9],.[0-9],-r[0-9]}*/ )
	${prev_shopt}
	echo "${result[@]}"
}

get_slot() {
	[[ $1 == *":"* ]] && echo "${1##*:}" || echo ""
}

## Print the ehooks directory used for an installed package ($1: /var/db/pkg directory),
## following the search order in profile.bashrc. Return 1 if there is none.
get_ehooks_dir() {
	local \
		installed_dir="${1%/}" \
		category p pf pkg pn pr slot

	pf=${installed_dir##*/}
	category=${installed_dir%/*}
	category=${category##*/}
	if [[ ${pf} =~ -(r[0-9]+)$ ]]; then
		pr=${BASH_REMATCH[1]}
		p=${pf%-r*}
	else
		pr="r0"
		p=${pf}
	fi
	pn=${p%-[0-9]*}
	slot=$(<"${installed_dir}/SLOT")
	slot=${slot%/*}

	for pkg in ${category}/{${p}-${pr},${p},${p%.*},${p%.*.*},${pn}}{:${slot},}; do
		if [[ -d ${REPO_ROOT}/ehooks/${pkg} ]]; then
			echo "${REPO_ROOT}/ehooks/${pkg}"
			return 0
		fi
	done
	return 1
}

## Print "atom|ehooks directory|install time" for installed packages older than their ehooks directory.
find_ehooks_changes() {
	local \
		atom ehooks_dir ehooks_pkg install_time installed_dir pkg_dir slot

	while read -r ehooks_dir; do
		## Get the package's ehooks directory and ${CATEGORY}/{${P}-${PR},${P},${P%.*},${P%.*.*},${PN}} from ehooks' path.
		pkg_dir=${ehooks_dir%%/files/*}
		pkg_dir=${pkg_dir%/files}
		ehooks_pkg=${pkg_dir#*/ehooks/}
		ehooks_pkg=${ehooks_pkg%:*}

		for installed_dir in $(get_installed_packages "${ehooks_pkg}"); do
			## Skip packages using another ehooks directory (a different slot or a more specific version).
			[[ $(get_ehooks_dir "${installed_dir}") == "${pkg_dir}" ]] || continue

			## Skip packages installed after the last ehooks (sub)directory change.
			install_time=$(date -r "${installed_dir}" "+%s")
			[[ ${install_time} -ge $(date -r "${ehooks_dir}" "+%s") ]] && continue

			## Get ${CATEGORY}/${PN}[:${SLOT}] (slot "0" is omitted).
			slot=$(<"${installed_dir}/SLOT")
			slot=${slot%/*}
			atom=${installed_dir%/}
			atom=${atom%-[0-9]*}
			atom=${atom#/var/db/pkg/}
			[[ ${slot} != 0 ]] && atom+=":${slot}"
			echo "${atom}|${ehooks_dir}|${install_time}"
		done
	done < <(find -L "${REPO_ROOT}"/ehooks -mindepth 2 -type d)
}

## Print packages affected by ehooks changes, one atom per line.
ehooks_rebuild_list() {
	find_ehooks_changes | cut -d "|" -f 1 | sort -u
}

## Print a notice about packages ($@) affected by ehooks changes.
ehooks_rebuild_notice() {
	[[ -z $* ]] && return 0

	local atom

	echo
	echo "${color_yellow}!!!${color_norm} packages affected by gentoo-unity7 ehooks changes:"
	for atom in "$@"; do
		echo "${color_yellow}>>>${color_norm} package: ${atom}"
	done
	echo "Use ${color_green}emerge @ehooks-rebuild${color_norm} to apply gentoo-unity7 ehooks changes to these packages"
	echo
}

## Mark ehooks changes as applied: set ehooks directories' mtime to the install time of affected packages.
## The oldest install time is applied last, so the change is marked as applied for every affected package.
ehooks_reset() {
	local \
		applied="" \
		atom ehooks_dir install_time

	while IFS="|" read -r atom ehooks_dir install_time; do
		if ! touch -m -d @"${install_time}" "${ehooks_dir}" 2>/dev/null; then
			echo
			eerror "Permission denied to apply reset (ownership $(stat -c '%U:%G' "${ehooks_dir}"))"
			echo
			exit 1
		fi
		applied="yes"
	done < <(find_ehooks_changes | sort -t "|" -k 3,3nr)

	echo
	if [[ -n ${applied} ]]; then
		einfo "Reset applied"
	else
		einfo "Reset not needed"
	fi
	echo
}

## Print "suite component" pairs of all used Ubuntu Sources files.
list_sources() {
	local component release suite

	for release in "${releases[@]}"; do
		for suite in "${release}" "${release}"-security "${release}"-updates; do
			for component in "${components[@]}"; do
				echo "${suite} ${component}"
			done
		done
	done
}

## Print the local path of a Sources file ($1: suite, $2: component).
sources_file() {
	echo "${sources_cache}/Sources-$1-$2"
}

## Download Sources files older than 20 hours.
download_sources() {
	local \
		downloaded="" \
		component file suite

	mkdir -p "${sources_cache}" || exit 1

	while read -r suite component; do
		file=$(sources_file "${suite}" "${component}")
		[[ -f ${file} ]] && [[ $(( $(date -r "${file}" "+%s") + 72000 )) -gt $(date "+%s") ]] && continue

		printf "%s" "Downloading ${suite}/${component} sources${color_blink}...${color_norm}"
		if wget -q -T 30 "http://archive.ubuntu.com/ubuntu/dists/${suite}/${component}/source/Sources.gz" -O "${file}.gz" \
			&& gunzip -qf "${file}.gz"; then
			touch "${file}"
			printf "\b\b\b%s\n" "... done!"
		else
			rm -f "${file}.gz"
			printf "\b\b\b%s\n" "... ${color_red}failed!${color_norm}"
		fi
		downloaded="yes"
	done < <(list_sources)

	[[ -n ${downloaded} ]] && echo
	return 0
}

## Check that all Sources files are available.
check_sources() {
	local \
		missing="" \
		component file suite

	while read -r suite component; do
		file=$(sources_file "${suite}" "${component}")
		if [[ ! -f ${file} ]]; then
			echo "${file}... ${color_red}file not found!${color_norm}"
			missing="yes"
		fi
	done < <(list_sources)

	[[ -z ${missing} ]]
}

## Print the version (without epoch) of a source package ($1) from a Sources file ($2).
get_upstream_version() {
	awk -v pkg="$1" '
		$1 == "Package:" { found = ($2 == pkg) }
		found && $1 == "Version:" { sub(/^[0-9]+:/, "", $2); print $2; exit }
	' "$2" 2>/dev/null
}

## Update version entries of packages maintained via ehooks in gentoo-unity7.mask ($1: repository path).
update_mask_entries() {
	local \
		repo_path="$1" \
		gentoo_repo=$(portageq get_repo_path / gentoo) \
		mask_file="$1/profiles/gentoo-unity7.mask" \
		unmask_link="/etc/portage/package.unmask/zzzz_ehooks-punmask.tmp" \
		keywords_link="/etc/portage/package.accept_keywords/zzzz_ehooks-paccept_keywords.tmp" \
		entry in_ehooks_section major_pkg mask_entry new_cpv new_pkg next_major old_pkg pkg slot tmp_keywords tmp_unmask

	local -a updates

	printf "%s\n\n" "${color_blue}Gentoo main portage:${color_norm}"

	if [[ ! -f ${mask_file} ]]; then
		eerror "'gentoo-unity7.mask' file not found"
		echo
		return 1
	fi

	printf "%s" "Looking for updates ${spinner[0]}"

	## Temporarily unmask packages maintained via ehooks and accept keywords from the list.
	## The temporary files and links are removed on exit, including interruption.
	tmp_unmask=$(mktemp) || exit 1
	tmp_keywords=$(mktemp) || exit 1
	trap "rm -f '${unmask_link}' '${keywords_link}' '${tmp_unmask}' '${tmp_keywords}'" EXIT
	trap "exit 1" INT TERM
	ln -fs "${tmp_unmask}" "${unmask_link}" || exit 1
	ln -fs "${tmp_keywords}" "${keywords_link}" || exit 1

	{
	while read -r mask_entry; do
		spinner_step

		## Read entries from the "maintained via ehooks" comment up to the next comment.
		if [[ -z ${in_ehooks_section} ]]; then
			[[ ${mask_entry} == *"maintained via ehooks"* ]] && in_ehooks_section="yes"
			continue
		fi
		[[ -z ${mask_entry} ]] && continue
		[[ ${mask_entry} == "#"* ]] && break

		echo "${mask_entry}" > "${tmp_unmask}"

		new_cpv=""
		for pkg in "${testing_packages[@]}"; do
			slot=$(get_slot "${pkg}")
			[[ -n ${slot} ]] && slot=":${slot}"
			if [[ ${mask_entry} == ">"${pkg%${slot}}*${slot} ]]; then
				echo "${pkg}" > "${tmp_keywords}"
				new_cpv=$(equery -q l -p -F '$cpv|$mask2' "${mask_entry}" | grep "|~amd64$" | tail -1 | sed "s/|.*$//")
				> "${tmp_keywords}"
				break
			fi
		done
		[[ -z ${new_cpv} ]] && \
			new_cpv=$(equery -q l -p -F '$cpv|$mask2' "${mask_entry}" | grep "|amd64$" | tail -1 | sed "s/|.*$//")
		[[ -n ${new_cpv} ]] && updates+=( "${mask_entry}|${new_cpv}" )
	done < "${mask_file}"
	} 2>/dev/null

	rm -f "${unmask_link}" "${keywords_link}" "${tmp_unmask}" "${tmp_keywords}"
	trap - EXIT INT TERM

	printf "\b\b%s\n\n" "... done!"

	if [[ -z ${updates[@]} ]]; then
		einfo "No updates found"
		echo
		return 0
	fi

	# Remove duplicates.
	updates=( $(printf "%s\n" "${updates[@]}" | sort -u) )

	echo " * Updates available:"
	echo
	for entry in "${updates[@]}"; do
		## Format: ">old_pkg:slot|new_pkg".
		old_pkg="${entry%|*}"; old_pkg="${old_pkg#>}"; slot=$(get_slot "${old_pkg}"); old_pkg="${old_pkg%:*}"
		new_pkg="${entry#*|}"
		echo " * Update to ${color_yellow}${new_pkg}${color_norm} (old pmask entry: ${color_bold}>${old_pkg}${color_norm})"
		printf "%s" " * Test command 'EHOOKS_PATH=${repo_path}/ehooks ebuild \$(portageq get_repo_path / gentoo)/${new_pkg%-[0-9]*}/${new_pkg#*/}.ebuild clean prepare clean'${color_blink}...${color_norm}"
		if EHOOKS_PATH="${repo_path}/ehooks" ebuild "${gentoo_repo}/${new_pkg%-[0-9]*}/${new_pkg#*/}".ebuild clean prepare clean 1>/dev/null; then
			printf "\b\b\b%s\n" "... ${color_blue}[ ${color_green}passed ${color_blue}]${color_norm}"
			## Mask the next major version of packages with the major version.
			for major_pkg in "${major_version_packages[@]}"; do
				if [[ ${new_pkg} == "${major_pkg}-"[0-9]* ]]; then
					next_major="${new_pkg#${major_pkg}-}"; next_major="${next_major%%.*}"; next_major=$((next_major + 1))
					new_pkg="${major_pkg}-${next_major}"
					break
				fi
			done
			if [[ -n ${slot} ]]; then
				old_pkg="${old_pkg}:${slot}"
				new_pkg="${new_pkg}:${slot}"
			fi
			sed -i "s|${old_pkg}$|${new_pkg}|" "${mask_file}" 2>/dev/null \
				&& echo " ${color_green}*${color_norm} New pmask entry: >${new_pkg}... ${color_blue}[ ${color_green}updated ${color_blue}]${color_norm}" \
				|| echo " ${color_red}*${color_norm} New pmask entry: >${new_pkg}... ${color_blue}[ ${color_red}not updated ${color_blue}]${color_norm}"
		else
			printf "\b\b\b%s\n" "... ${color_blue}[ ${color_red}failed ${color_blue}]${color_norm}"
		fi
		echo
	done
}

## Print "ehooks file|uver" of {pre,post}_src_unpack.ehooks ($1: repository path, $@: packages, all if none).
get_ehooks_uvers() {
	local \
		repo_path="$1" \
		ehooks_file pkg uver

	local -a \
		ehooks_files \
		result

	shift
	if [[ -n $* ]]; then
		for pkg in "$@"; do
			ehooks_files+=( $(ehooks_glob "${repo_path}/" "${pkg}/*src_unpack.ehooks") )
		done
	else
		ehooks_files=( $(ehooks_glob "${repo_path}/" "*/*/*src_unpack.ehooks") )
	fi

	for ehooks_file in "${ehooks_files[@]}"; do
		uver=$(grep -Eo -m 1 "uver=[^[:space:]]+" "${ehooks_file}")
		[[ -n ${uver} ]] && result+=( "${ehooks_file}|${uver#uver=}" )
	done
	echo "${result[@]}"
}

## Download a debian archive for uver ($1) to /tmp; $2 is an optional file name (always downloaded).
get_debian_archive() {
	local \
		archive filename tmp

	local -a filenames=( "$1.debian.tar.xz" "$1.debian.tar.gz" )

	for filename in "${filenames[@]}"; do
		archive="/tmp/${2:-ehooks-${USER}-${filename}}"

		[[ -z $2 ]] && [[ -s ${archive} ]] && tar -tf "${archive}" >/dev/null 2>&1 && return 0

		tmp=$(mktemp "${archive}.XXXXXX") || return 1
		if wget -q -T 60 \
			"https://launchpad.net/ubuntu/+archive/primary/+files/${filename}" \
			-O "${tmp}"; then
			mv -f "${tmp}" "${archive}" && return 0
		fi

		rm -f "${tmp}"
	done

	return 1
}

## Extract debian/patches/series of a downloaded debian archive for uver ($1) to a file ($2).
extract_debian_series() {
	local \
		uver="$1" \
		target="$2" \
		archive

	: > "${target}"
	for archive in \
		"/tmp/ehooks-${USER}-${uver}.debian.tar.xz" \
		"/tmp/ehooks-${USER}-${uver}.debian.tar.gz"; do
		[[ -f ${archive} ]] || continue
		tar -xOf "${archive}" debian/patches/series > "${target}" 2>/dev/null && return 0
		: > "${target}"
	done

	return 1
}

## Check debian archive files used by ehooks ($1: action, $2: optional repository path, $@: packages).
## -b|--blake updates BLAKE2 checksums, -c|--changes looks for available versions.
debian_changes() {
	local \
		action="$1" \
		ehooks_file ehooks_pkg entry repo_path uver

	local -a \
		notes \
		result \
		uvers

	shift
	## The first argument is an optional development repository path.
	if [[ -n $1 ]] && grep -Fqsx "gentoo-unity7" "$1"/profiles/repo_name; then
		repo_path=$(get_dev_repo "$1") || exit 1
		shift
	else
		repo_path=$(get_dev_repo) || exit 1
	fi

	uvers=( $(get_ehooks_uvers "${repo_path}" "$@") )
	if [[ -z ${uvers[@]} ]]; then
		[[ -n $* ]] && eerror "No package found! Package name must be in format: \${CATEGORY}/\${PN}." || eerror "No package found."
		echo
		exit 1
	fi

	case ${action} in
		-b|--blake)
			local blake old_checksum

			printf "%s" "Looking for BLAKE2 checksum changes${color_blink}...${color_norm}"

			for entry in "${uvers[@]}"; do
				## Format: "ehooks file|uver".
				ehooks_file="${entry%|*}"
				uver="${entry#*|}"
				ehooks_pkg="${ehooks_file#${repo_path}/ehooks/}"; ehooks_pkg="${ehooks_pkg%/*}"
				if get_debian_archive "${uver}" "ehooks-${USER}-debian.tmp"; then
					blake=$(b2sum "/tmp/ehooks-${USER}-debian.tmp" | cut -d " " -f 1)
					old_checksum=$(b2sum "${ehooks_file}")
					sed -i -e "s/blake=[[:alnum:]]*/blake=${blake}/" "${ehooks_file}"
					[[ ${old_checksum} != $(b2sum "${ehooks_file}") ]] && result+=( " ${color_green}*${color_norm} ${ehooks_pkg}... ${color_blue}[ ${color_green}updated ${color_blue}]${color_norm}" )
				else
					result+=( " ${color_red}*${color_norm} ${ehooks_pkg}... ${color_blue}[ ${color_red}debian file not found${color_blue} ]${color_norm}" )
				fi
			done
			;;
		-c|--changes)
			local \
				local_series="/tmp/ehooks-${USER}-series" \
				upstream_series="/tmp/ehooks-${USER}-aseries" \
				component local_label pkg_label prev_upstream_ver suite up_to_date upstream_ver versions_label

			local -a upstream_vers

			require_tool equery app-portage/gentoolkit
			require_tool qlist app-portage/portage-utils
			download_sources
			check_sources || exit 1

			printf "%s" "Looking for available version changes${color_blink}...${color_norm}"

			for entry in "${uvers[@]}"; do
				## Format: "ehooks file|uver", uver format: "${source package}_${version}".
				ehooks_file="${entry%|*}"
				uver="${entry#*|}"
				ehooks_pkg="${ehooks_file#${repo_path}/ehooks/}"; ehooks_pkg="${ehooks_pkg%/*}"
				upstream_vers=()
				prev_upstream_ver=""
				up_to_date=""

				## Collect Ubuntu versions different from the local one.
				while read -r suite component; do
					upstream_ver=$(get_upstream_version "${uver%_*}" "$(sources_file "${suite}" "${component}")")
					[[ -z ${upstream_ver} ]] && continue
					if [[ ${upstream_ver} == "${uver#*_}" ]]; then
						up_to_date="yes"
					elif [[ ${upstream_ver} != "${prev_upstream_ver}" ]]; then
						upstream_vers+=( "${upstream_ver}" )
						prev_upstream_ver="${upstream_ver}"
					fi
				done < <(list_sources)

				[[ -z ${upstream_vers[@]} ]] && continue

				if [[ -n ${up_to_date} ]]; then
					local_label="${color_green}${uver#*_}${color_norm}"
				else
					local_label="${color_yellow}${uver#*_}${color_norm}"
					notes[1]="${color_yellow}[ package is outdated ]${color_norm}"
				fi

				pkg_label=$(equery -q l -p -F '$cpv|$mask2' "${ehooks_pkg}" | grep "|amd64$" | tail -1 | sed "s/|.*$//")
				if [[ -z ${pkg_label} ]]; then
					pkg_label=$(qlist -Iv "${ehooks_pkg}")
					pkg_label="${color_bold}${color_cyan}${pkg_label:-${ehooks_pkg}}${color_norm}"
					notes[0]="${color_bold}${color_cyan}[ package is masked ]${color_norm}"
				fi

				if get_debian_archive "${uver}"; then
					extract_debian_series "${uver}" "${local_series}"
				else
					: > "${local_series}"
				fi

				## Mark versions with a different debian/patches/series file.
				versions_label=""
				for upstream_ver in "${upstream_vers[@]}"; do
					if get_debian_archive "${uver%_*}_${upstream_ver}"; then
						extract_debian_series "${uver%_*}_${upstream_ver}" "${upstream_series}"
					else
						: > "${upstream_series}"
					fi

					if cmp -s "${local_series}" "${upstream_series}"; then
						versions_label+=" '${upstream_ver}'"
					else
						versions_label+=" '${color_red}${upstream_ver}${color_norm}'"
						notes[2]="${color_red}[ debian/patches/series file differs from local ]${color_norm}"
					fi
				done

				result+=( " * ${pkg_label}... local: ${local_label} available:${versions_label}" )
			done
			;;
	esac
	printf "\b\b\b%s\n\n" "... done!"

	if [[ -n ${result[@]} ]]; then
		printf "%s\n\n" "${result[@]}"
		if [[ -n ${notes[@]} ]]; then
			printf "%s\n" "${notes[@]}"
			echo
		fi
	else
		einfo "No changes found"
		echo
	fi
}

## Compare overlay package versions with Ubuntu versions ($1: repository path).
check_overlay_updates() {
	local \
		repo_path="$1" \
		found="" \
		component ebuild keyword local_ver pkg pn prev_upstream_ver release suite upstream_name upstream_ver value

	local -a packages

	printf "%s\n\n" "${color_blue}Overlay:${color_norm}"
	tput sc 2>/dev/null
	printf "%s" "Looking for updates ${spinner[0]}"

	for pkg in $(find "${repo_path}" -type f -name "*.ebuild" | rev | cut -d "/" -f 2,3 | rev | sort -u); do
		[[ -v skip_packages["${pkg}"] ]] || packages+=( "${pkg}" )
	done

	for pkg in "${packages[@]}"; do
		spinner_step

		pn=${pkg#*/}
		upstream_name=${upstream_names["${pkg}"]:-${pn}}
		local_ver=""
		prev_upstream_ver=""

		for release in "${releases[@]}"; do
			[[ ${release} == "${stable_release}" ]] && keyword="\"amd64\"" || keyword="\"~amd64\""
			for suite in "${release}"-updates "${release}"-security "${release}"; do
				for component in "${components[@]}"; do
					upstream_ver=$(get_upstream_version "${upstream_name}" "$(sources_file "${suite}" "${component}")")
					[[ -z ${upstream_ver} ]] && continue

					if [[ ${pkg} == "dev-libs/libindicator" ]] || [[ ${pkg} == "dev-libs/libappindicator" ]]; then
						ebuild=$(grep -H -- "${keyword}" "${repo_path}/${pkg}"/*r2*.ebuild 2>/dev/null | cut -d ":" -f 1)
						[[ ${ebuild} == *".ebuild"*".ebuild"* ]] \
							|| ebuild=$(grep -H -- "${keyword}" "${repo_path}/${pkg}"/*r3*.ebuild 2>/dev/null | cut -d ":" -f 1)
					else
						ebuild=$(grep -H -- "${keyword}" "${repo_path}/${pkg}"/*.ebuild 2>/dev/null | cut -d ":" -f 1)
					fi
					if [[ ${ebuild} == *".ebuild"*".ebuild"* ]]; then
						printf "\b\b%s\n\n" "... error!"
						printf "%s\n\n" " ${color_red}*${color_norm} ${pkg}: multiple files with KEYWORDS=${keyword}"
						exit 1
					fi

					if [[ -n ${ebuild} ]]; then
						## Skip packages without Ubuntu version.
						grep -q -- "^UVER=" "${ebuild}" || break 3

						## Get ${PV} without revision followed by UVER and UREV.
						local_ver="${ebuild#${repo_path}/${pkg}/${pn}-}"
						if [[ ${local_ver} != *"-r"* ]]; then
							local_ver=""
							continue
						fi
						local_ver="${local_ver%-r*}"
						value=$(grep -- "^UVER=" "${ebuild}" | cut -d "=" -f 2)
						value=${value//\"}
						local_ver+=${value}
						value=$(grep -- "^UREV=" "${ebuild}" | cut -d "=" -f 2)
						value=${value//\"}
						local_ver+=${value:+-${value}}
						prev_upstream_ver="${upstream_ver}"
					else
						## No ebuild for this release: report only versions not reported for the previous release.
						[[ ${local_ver} == "${upstream_ver}" ]] && upstream_ver=""
						local_ver=""
						[[ ${prev_upstream_ver} == "${upstream_ver}" ]] && upstream_ver=""
					fi

					[[ -z ${local_ver} ]] && [[ -z ${upstream_ver} ]] && continue
					[[ ${local_ver} == "${upstream_ver}" ]] && break 2

					found="yes"
					tput rc 2>/dev/null; tput el 2>/dev/null
					echo "Overlay:  ${pkg}-${color_yellow}${local_ver:-none}${color_norm} (${release})"
					echo "Upstream: ${pkg}-${color_green}${upstream_ver}${color_norm} (${release})"
					echo
					tput sc 2>/dev/null
					printf "%s" "Looking for updates ${spinner[spinner_pos]}"
				done
			done
		done
	done

	printf "\b\b%s\n\n" "... done!"
	if [[ -z ${found} ]]; then
		printf "%s\n\n" " ${color_green}*${color_norm} No updates found"
	fi
}

## Update unity-lens/unity-scope-extras version entries ($1: repository path).
update_scopes() {
	local \
		repo_path="$1" \
		found="" \
		ebuild keyword local_ver prev_upstream_ver release scope suite upstream_name upstream_ver urev uver

	local -a \
		ebuilds \
		scopes

	printf "%s\n\n" "${color_blue}Scopes:${color_norm}"
	tput sc 2>/dev/null
	printf "%s" "Looking for updates ${spinner[0]}"

	ebuilds=( $(find "${repo_path}" -type f -name "unity-scope-extras*.ebuild") )
	## Format: "scope|uver|urev".
	scopes=( $(grep -- "^setvar " "${ebuilds[@]}" | awk '{ print $2 "|" $3 "|" $4 }' | sort -u) )
	for scope in "${scopes[@]}"; do
		spinner_step

		upstream_name="unity-scope-${scope%%|*}"
		uver="${scope#*|}"; uver="${uver%|*}"
		urev="${scope##*|}"
		local_ver=""
		prev_upstream_ver=""

		for release in "${releases[@]}"; do
			[[ ${release} == "${stable_release}" ]] && keyword="\"amd64\"" || keyword="\"~amd64\""
			for suite in "${release}" "${release}"-security "${release}"-updates; do
				upstream_ver=$(get_upstream_version "${upstream_name}" "$(sources_file "${suite}" universe)")
				[[ -z ${upstream_ver} ]] && continue

				ebuild=$(grep -H -- "${keyword}" "${ebuilds[@]}" | cut -d ":" -f 1)
				if [[ ${ebuild} == *".ebuild"*".ebuild"* ]]; then
					printf "\b\b%s\n\n" "... error!"
					printf "%s\n\n" " ${color_red}*${color_norm} unity-lens/unity-scope-extras: multiple files with KEYWORDS=${keyword}"
					exit 1
				fi

				if [[ -n ${ebuild} ]] && [[ $(grep -- "^setvar ${scope%%|*} " "${ebuild}") == *" ${uver} "*" ${urev} "* ]]; then
					local_ver="${uver}-${urev}"
					prev_upstream_ver="${upstream_ver}"
				else
					[[ ${local_ver} == "${upstream_ver}" ]] && upstream_ver=""
					local_ver=""
					[[ ${prev_upstream_ver} == "${upstream_ver}" ]] && upstream_ver=""
					[[ -n ${ebuild} ]] && [[ ${release} == "${dev_release}" ]] && continue
				fi

				[[ -z ${local_ver} ]] && [[ -z ${upstream_ver} ]] && continue
				[[ ${local_ver} == "${upstream_ver}" ]] && continue

				found="yes"
				tput rc 2>/dev/null; tput el 2>/dev/null
				echo "Overlay:  ${upstream_name}-${color_yellow}${local_ver:-none}${color_norm} (${release})"
				printf "%s" "Upstream: ${upstream_name}-${color_green}${upstream_ver}${color_norm} (${release})"
				if [[ -n ${local_ver} ]]; then
					sed -i \
						-e "/^setvar ${scope%%|*} /{s/ ${uver} / ${upstream_ver%-*} /}" \
						-e "/^setvar ${scope%%|*} /{s/ ${urev} / ${upstream_ver##*-} /}" \
						"${ebuild}" 2>/dev/null \
						&& printf "%s\n" "... ${color_blue}[ ${color_green}updated ${color_blue}]${color_norm}" \
						|| printf "%s\n" "... ${color_blue}[ ${color_red}not updated ${color_blue}]${color_norm}"
				else
					printf "\n"
				fi
				echo
				tput sc 2>/dev/null
				printf "%s" "Looking for updates ${spinner[spinner_pos]}"
			done
		done
	done

	printf "\b\b%s\n\n" "... done!"
	if [[ -z ${found} ]]; then
		printf "%s\n\n" " ${color_green}*${color_norm} No updates found"
	fi
}

## Update unity-base/unity-language-pack version entries ($1: repository path).
update_languages() {
	local \
		repo_path="$1" \
		found="" \
		base_name base_ver ebuild gnome_name gnome_ver keyword language local_gnome_ver local_ver prev_upstream_gnome_ver prev_upstream_ver release tag upstream_gnome_ver upstream_ver

	local -a \
		ebuilds \
		languages

	printf "%s\n\n" "${color_blue}Languages:${color_norm}"
	tput sc 2>/dev/null
	printf "%s" "Looking for updates ${spinner[0]}"

	ebuilds=( $(find "${repo_path}" -type f -name "unity-language-pack*.ebuild") )
	## Format: "language|base version|gnome version|tag".
	languages=( $(grep -- "^setvar " "${ebuilds[@]}" | sed -E 's/[ \t]+/|/g' | cut -d "|" -f 2,3,4,5 | sort -u) )
	for language in "${languages[@]}"; do
		spinner_step

		tag=$(echo "${language}" | cut -d "|" -f 4)
		[[ -z ${tag} ]] && tag="${language%%|*}"
		base_name="language-pack-${tag}-base"
		gnome_name="language-pack-gnome-${tag}-base"
		base_ver=$(echo "${language}" | cut -d "|" -f 2)
		gnome_ver=$(echo "${language}" | cut -d "|" -f 3)
		local_ver=""
		local_gnome_ver=""
		prev_upstream_ver=""
		prev_upstream_gnome_ver=""

		for release in "${releases[@]}"; do
			upstream_ver=$(get_upstream_version "${base_name}" "$(sources_file "${release}" main)")
			upstream_gnome_ver=$(get_upstream_version "${gnome_name}" "$(sources_file "${release}" main)")
			[[ -z ${upstream_ver} && -z ${upstream_gnome_ver} ]] && continue

			[[ ${release} == "${stable_release}" ]] && keyword="\"amd64\"" || keyword="\"~amd64\""
			ebuild=$(grep -H -- "${keyword}" "${ebuilds[@]}" | cut -d ":" -f 1)
			if [[ ${ebuild} == *".ebuild"*".ebuild"* ]]; then
				printf "\b\b%s\n\n" "... error!"
				printf "%s\n\n" " ${color_red}*${color_norm} unity-base/unity-language-pack: multiple files with KEYWORDS=${keyword}"
				exit 1
			fi

			if [[ -n ${ebuild} ]] && [[ $(awk -v lang="${language%%|*}" '$1 == "setvar" && $2 == lang { print $3 "|" $4 }' "${ebuild}") == "${base_ver}|${gnome_ver}" ]]; then
				local_ver="${base_ver}"
				local_gnome_ver="${gnome_ver}"
				prev_upstream_ver="${upstream_ver}"
				prev_upstream_gnome_ver="${upstream_gnome_ver}"
			else
				[[ ${local_ver} == "${upstream_ver}" ]] && upstream_ver=""
				local_ver=""
				[[ ${local_gnome_ver} == "${upstream_gnome_ver}" ]] && upstream_gnome_ver=""
				local_gnome_ver=""
				[[ ${prev_upstream_ver} == "${upstream_ver}" ]] && upstream_ver=""
				[[ ${prev_upstream_gnome_ver} == "${upstream_gnome_ver}" ]] && upstream_gnome_ver=""
				[[ -n ${ebuild} ]] && [[ ${release} == "${dev_release}" ]] && continue
			fi

			[[ -z ${local_ver} ]] && [[ ${release} == "${stable_release}" ]] && continue
			[[ -z ${local_ver} ]] && [[ -z ${upstream_ver} ]] && [[ -z ${local_gnome_ver} ]] && [[ -z ${upstream_gnome_ver} ]] && continue
			[[ ${local_ver} == "${upstream_ver}" ]] && [[ ${local_gnome_ver} == "${upstream_gnome_ver}" ]] && continue
			[[ ${local_ver#*+} -gt ${upstream_ver#*+} && ${local_gnome_ver#*+} -gt ${upstream_gnome_ver#*+} ]] && continue

			found="yes"
			tput rc 2>/dev/null; tput el 2>/dev/null
			if [[ ${local_ver#*+} -lt ${upstream_ver#*+} ]]; then
				echo "Overlay:  ${base_name}-${color_yellow}${local_ver:-new}${color_norm} (${release})"
				printf "%s" "Upstream: ${base_name}-${color_green}${upstream_ver}${color_norm} (${release})"
				if [[ -n ${local_ver} ]]; then
					sed -i "/^setvar ${language%%|*} /{s/^\(setvar [^ ]*  *\)${local_ver} /\1${upstream_ver} /}" "${ebuild}" 2>/dev/null \
						&& printf "%s\n" "... ${color_blue}[ ${color_green}updated ${color_blue}]${color_norm}" \
						|| printf "%s\n" "... ${color_blue}[ ${color_red}not updated ${color_blue}]${color_norm}"
				else
					printf "\n"
				fi
			fi
			if [[ ${local_gnome_ver#*+} -lt ${upstream_gnome_ver#*+} ]]; then
				echo "Overlay:  ${gnome_name}-${color_yellow}${local_gnome_ver:-new}${color_norm} (${release})"
				printf "%s" "Upstream: ${gnome_name}-${color_green}${upstream_gnome_ver}${color_norm} (${release})"
				if [[ -n ${local_gnome_ver} ]]; then
					sed -i "/^setvar ${language%%|*} /{s/^\(setvar [^ ]*  *[^ ]*  *\)${local_gnome_ver}/\1${upstream_gnome_ver}/}" "${ebuild}" 2>/dev/null \
						&& printf "%s\n" "... ${color_blue}[ ${color_green}updated ${color_blue}]${color_norm}" \
						|| printf "%s\n" "... ${color_blue}[ ${color_red}not updated ${color_blue}]${color_norm}"
				else
					printf "\n"
				fi
			fi
			echo
			tput sc 2>/dev/null
			printf "%s" "Looking for updates ${spinner[spinner_pos]}"
		done
	done

	printf "\b\b%s\n\n" "... done!"
	if [[ -z ${found} ]]; then
		printf "%s\n\n" " ${color_green}*${color_norm} No updates found"
	fi
}

case $1 in
	-b|--blake|-c|--changes)
		debian_changes "$@"
		;;
	-l|--list)
		ehooks_rebuild_list
		;;
	-n|--notice)
		ehooks_rebuild_notice $(ehooks_rebuild_list)
		;;
	-r|--reset)
		ehooks_reset
		;;
	-u|--update)
		dev_repo=$(get_dev_repo "$2") || exit 1
		require_tool equery app-portage/gentoolkit
		if [[ ! -w /etc/portage/package.unmask || ! -w /etc/portage/package.accept_keywords ]]; then
			echo
			eerror "Permission denied to perform 'update'!"
			echo
			exit 1
		fi
		download_sources
		check_sources || exit 1
		update_mask_entries "${dev_repo}"
		update_languages "${dev_repo}"
		update_scopes "${dev_repo}"
		check_overlay_updates "${dev_repo}"
		;;
	*)
		echo "${color_blue}NAME${color_norm}"
		echo "	version_control.sh"
		echo
		echo "${color_blue}SYNOPSIS${color_norm}"
		echo "	${color_blue}gentoo-unity-ver${color_norm} [${color_cyan}OPTION${color_norm}]"
		echo
		echo "${color_blue}DESCRIPTION${color_norm}"
		echo "	Gentoo Unity⁷ version control tool."
		echo
		echo "	/usr/bin/${color_blue}gentoo-unity-ver${color_norm} is a symlink to gentoo-unity7/version_control.sh script."
		echo
		echo "${color_blue}OPTIONS${color_norm}"
		echo "	${color_blue}-b${color_norm}, ${color_blue}--blake${color_norm} [${color_cyan}${color_underline}repo path${color_underline_end}${color_norm}] [${color_cyan}${color_underline}packages${color_underline_end}${color_norm}]"
		echo "		It updates BLAKE2 checksum of debian archive file in {pre,post}_src_unpack.ehooks."
		echo
		echo "	${color_blue}-c${color_norm}, ${color_blue}--changes${color_norm} [${color_cyan}${color_underline}repo path${color_underline_end}${color_norm}] [${color_cyan}${color_underline}packages${color_underline_end}${color_norm}]"
		echo "		It looks for available version changes of debian archive file."
		echo
		echo "	${color_blue}-l${color_norm}, ${color_blue}--list${color_norm}"
		echo "		It lists packages affected by ehooks changes, one atom per line (used by the @ehooks-rebuild package set)."
		echo
		echo "	${color_blue}-n${color_norm}, ${color_blue}--notice${color_norm}"
		echo "		It prints a notice about packages affected by ehooks changes only if a rebuild is needed (used by the repo.postsync.d hook)."
		echo
		echo "	${color_blue}-r${color_norm}, ${color_blue}--reset${color_norm}"
		echo "		It looks for ehooks changes and sets them as applied (it resets modification time)."
		echo
		echo "	${color_blue}-u${color_norm}, ${color_blue}--update${color_norm} [${color_cyan}${color_underline}repo path${color_underline_end}${color_norm}]"
		echo "		It updates gentoo-unity7.mask version entries (it needs temporary access to /etc/portage/package.{unmask,accept_keywords}), unity-base/unity-language-pack version entries, unity-lens/unity-scope-extras version entries and it looks for available packages updates."
		echo
		exit 1
esac
