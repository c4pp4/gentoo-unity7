#!/bin/bash

stable="plucky"
dev="questing"
repos=(
	main
	universe
)

## Don't check these packages.
remove=(
	app-eselect/eselect-lightdm
	dev-java/jayatana
	net-libs/gnome-online-accounts
	unity-base/gentoo-unity-env
	unity-base/ubuntu-docs
	unity-base/unity-language-pack
	unity-base/unity-meta
	unity-base/unity-settings
	unity-extra/indicator-netspeed
	unity-extra/indicator-privacy
	unity-indicators/unity-indicators-meta
	unity-lenses/unity-lens-meta
	unity-scopes/smart-scopes
	x11-plugins/mailnag-messagingmenu-plugin
	x11-themes/adwaita-icon-theme
)

## Temporarily accept keywords from testing branch.
akwords=(
	app-backup/deja-dup
	www-client/firefox:esr
	www-client/firefox:rapid
)

## Packages with the major version (without slot).
majorver=(
	mail-client/thunderbird
	sys-devel/gcc
	www-client/firefox
)

color_blink=$(tput blink)
color_blue=$(tput bold; tput setaf 4)
color_cyan=$(tput setaf 6)
color_green=$(tput bold; tput setaf 2)
color_norm=$(tput sgr0)
color_red=$(tput bold; tput setaf 1)
color_yellow=$(tput bold; tput setaf 3)

count=1
indicator=( "|" "/" "-" "\\" )

einfo() {
	echo " $(tput bold; tput setaf 2)*$(tput sgr0) $*"
}

ewarn() {
	echo " $(tput bold; tput setaf 3)*$(tput sgr0) $*"
}

eerror() {
	echo " ${color_red}*${color_norm} $*"
}

get_subdirs() {
	local prev_shopt=$(shopt -p nullglob)
	shopt -s nullglob
	local -a result=( "$1"profiles/ehooks/$2 )
	${prev_shopt}

	echo "${result[@]}"
}

get_repo_root() {
	echo $(portageq get_repo_path / gentoo-unity7)
}

get_ehooks_subdirs() {
	local \
		repo_root=$(get_repo_root) \
		wildcard="*/*/"

	local -a \
		helper=( "n" ) \
		result

	while [[ -n ${helper[@]} ]]; do
		helper=( $(get_subdirs "${repo_root}/" "${wildcard}") )
		result+=( "${helper[@]}" )
		wildcard+="*/"
	done
	echo "${result[@]}"
}

get_installed_packages() {
	local \
		prev_shopt=$(shopt -p nullglob) \
		sys_db="/var/db/pkg"

	local -a result

	shopt -s nullglob ## don't use extglob
	[[ -d ${sys_db}/$1 ]] && result=( "${sys_db}/$1" ) || result=( "${sys_db}/$1"{-[0-9],.[0-9],-r[0-9]}*/ )
	${prev_shopt}
	echo "${result[@]}"
}

get_slot() {
	[[ $1 == *":"* ]] && echo "${1##*:}" || echo ""
}

find_flag_changes() {
	local \
		reset="$1" \
		sys_db="/var/db/pkg/" \
		ts_file="/etc/gentoo-unity7/timestamps" \
		flag line n slot sys_date ts x

	local -a result

	[[ ! -e ${ts_file} ]] && return

	while read -r line; do
		[[ ${line} == "##"* ]] && continue
		x="${line%%|*}"
		flag=$(echo "${line}" | cut -d "|" -f 2)
		portageq has_version / unity-base/gentoo-unity-env["${flag}"] \
			&& ts=$(echo "${line}" | cut -d "|" -f 3) \
			|| ts=$(echo "${line}" | cut -d "|" -f 4)
		slot=$(get_slot "${x}")

		pkg=( $(get_installed_packages "${x%:*}") )
		for n in "${pkg[@]}"; do
			## Try another package if slot differs.
			grep -Fqsx "${slot:-0}" "${n}/SLOT" || grep -qs "^${slot:-0}/" "${n}/SLOT" || continue

			## Try another package if modification time is newer or equal to ehooks USE flag change time.
			sys_date=$(date -r "${n}" "+%s")
			[[ ${sys_date} -ge ${ts} ]] && continue

			## Set USE flag change time equal to package's time when --reset option given.
			if [[ -n ${reset} ]]; then
				if portageq has_version / unity-base/gentoo-unity-env["${flag}"]; then
					sed -i -e "/${x/\//\\/}|${flag}/{s/|[0-9]\{10\}|/|${sys_date}|/}" "${ts_file}" 2>/dev/null && reset="applied" && continue
				else
					sed -i -e "/${x/\//\\/}|${flag}/{s/|[0-9]\{10\}$/|${sys_date}/}" "${ts_file}" 2>/dev/null && reset="applied" && continue
				fi
			fi
			## Get ownership of file when 'touch: cannot touch "${x}": Permission denied' and quit.
			[[ -n ${reset} ]] && reset=$(stat -c "%U:%G" "${ts_file}") && break 2

			## Get ${CATEGORY}/${PN}[:${slot}].
			n="${n%-[0-9]*}"
			n="${n#${sys_db}}"
			[[ -n ${slot} ]] && n="${n}:${slot}"
			result+=( "${n}" )
		done
	done < "${ts_file}"
	[[ -n ${reset} ]] && echo "${reset}" || echo "${result[@]}"
}

find_tree_changes() {
	local \
		reset="$1" \
		sys_db="/var/db/pkg/" \
		f m n slot x

	local -a \
		subdirs=( $(get_ehooks_subdirs) ) \
		flags result

	for x in "${subdirs[@]}"; do
		## Get ${CATEGORY}/{${P}-${PR},${P},${P%.*},${P%.*.*},${PN}} from ehooks' path.
		m=${x%%/files/*}
		m=${m%/}
		m=${m#*/ehooks/}
		slot=$(get_slot "${m}")
		m="${m%:*}"

		pkg=( $(get_installed_packages "${m}") )
		for n in "${pkg[@]}"; do
			## Try another package if slot differs.
			grep -Fqsx "${slot:-0}" "${n}/SLOT" || grep -qs "^${slot:-0}/" "${n}/SLOT" || continue

			## Try another package if modification time is newer or equal to ehooks (sub)directory time.
			sys_date=$(date -r "${n}" "+%s")
			[[ ${sys_date} -ge $(date -r "${x}" "+%s") ]] && continue

			## Try another package if ehooks_{require,use} flag is not declared.
			flags=( $(grep -Ehos "ehooks_(require|use)\s[A-Za-z0-9+_@-]+" "${x%%/files/*}/"*.ehooks) )
			if [[ -n ${flags[@]} ]]; then
				flags=( ${flags[@]/ehooks_require} ); flags=( ${flags[@]/ehooks_use} )
				for f in "${flags[@]}"; do
					portageq has_version / unity-base/gentoo-unity-env["${f}"] && break
					[[ ${f} == ${flags[-1]} ]] && continue 2
				done
			fi

			## Set ehooks' modification time equal to package's time when --reset option given.
			[[ -n ${reset} ]] && touch -m -t $(date -d @"${sys_date}" +%Y%m%d%H%M.%S) "${x}" 2>/dev/null && reset="applied" && continue
			## Get ownership of file when 'touch: cannot touch "${x}": Permission denied' and quit.
			[[ -n ${reset} ]] && reset=$(stat -c "%U:%G" "${x}") && break 2

			## Get ${CATEGORY}/${PN}[:${slot}].
			n="${n%-[0-9]*}"
			n="${n#${sys_db}}"
			[[ -n ${slot} ]] && n="${n}:${slot}"
			result+=( "${n}" )
		done
	done
	[[ -n ${reset} ]] && echo "${reset}" || echo "${result[@]}"
}

ehooks_changes() {
	local -a result

	if [[ -n $1 ]] && ( [[ ! -w $(get_repo_root)/profiles/ehooks ]] || [[ ! -w /etc/gentoo-unity7/timestamps ]] ); then
		## Get ownership when write permission denied.
		result=( $(stat -c '%U:%G' $(get_repo_root)/profiles/ehooks) $(stat -c '%U:%G' /etc/gentoo-unity7/timestamps) )
		# Remove duplicates.
		result=( $(printf "%s\n" "${result[@]}" | sort -u) )
		echo
		eerror "Permission denied to apply reset (ownership ${result[@]})"
		echo
		exit 1
	fi

	printf "%s" "Looking for ehooks changes${color_blink}...${color_norm}"

	result=( $(find_tree_changes "$1") $(find_flag_changes "$1") )
	# Remove duplicates.
	result=( $(printf "%s\n" "${result[@]}" | sort -u) )

	printf "\b\b\b%s\n\n" "... done!"

	if [[ -z ${result[@]} ]]; then
		einfo "No rebuild needed"
	elif [[ ${result[0]} == *"/"* ]] && ( [[ -z ${result[1]} ]] || [[ ${result[1]} == *"/"* ]] ); then
		ewarn "Rebuild the following packages affected by ehooks changes:"
		ewarn "emerge -av1 ${result[@]}"
	else
		case ${result[@]} in
			applied|"applied reset"|"reset applied")
				einfo "Reset applied"
				;;
			reset)
				einfo "Reset not needed"
				;;
			*)
				result=( ${result[@]/applied} ); result=( ${result[@]/reset} )
				result=( ${result[@]# } ); result=( ${result[@]% } )
				eerror "Permission denied to apply reset (ownership ${result[@]})"
				;;
		esac
	fi
	echo
}

check_path() {
	[[ -z $1 ]] && [[ ${PWD} == $(get_repo_root) ]] && echo && eerror "Don't run 'check' inside installed repo!" && echo && exit 1
	[[ -z $1 ]] && ! grep -Fq "gentoo-unity7" "${PWD}"/profiles/repo_name 2>/dev/null && echo && eerror "Run 'check' inside dev repo or set path!" && echo && exit 1
	[[ -n $1 ]] && ! grep -Fq "gentoo-unity7" "${PWD}"/profiles/repo_name 2>/dev/null && ! grep -Fq "gentoo-unity7" "$1"/profiles/repo_name 2>/dev/null && echo && eerror "Dev repo path not found!" && echo && exit 1
}

portage_updates() {
	[[ $(type -P equery) != "/usr/bin/equery" ]] && echo && eerror "'equery' tool from 'app-portage/gentoolkit' package not found!" && echo && exit 1
	[[ ! -w /etc/portage/package.unmask ]] && echo && eerror "Permission denied to perform 'update'!" && echo && exit 1
	check_path "$1"

	printf "%s\n\n" "${color_blue}Gentoo main portage:${color_norm}"
	printf "%s" "Looking for updates ${indicator[0]}"

	local \
		main_repo="$(portageq get_repo_path / gentoo)" \
		tmp_um=ehooks-punmask.tmp \
		tmp_ak=ehooks-paccept_keywords.tmp \
		line new_pkg old_pkg pmask slot start_reading update x y

	local -a updates

	[[ -z $1 ]] && pmask="${PWD}" || pmask="$1"
	pmask+="/profiles/gentoo-unity7.mask"

	## Temporarily unmask packages maintained via ehooks.
	install -m 666 /dev/null /tmp/"${tmp_um}" || exit 1
	ln -fs /tmp/"${tmp_um}" /etc/portage/package.unmask/zzzz_"${tmp_um}" || exit 1
	## Temporarily accept_keywords from the list.
	install -m 666 /dev/null /tmp/"${tmp_ak}" || exit 1
	ln -fs /tmp/"${tmp_ak}" /etc/portage/package.accept_keywords/zzzz_"${tmp_ak}" || exit 1

{
	while read -r line; do
		printf "\b\b %s" "${indicator[${count}]}"
		count=$((count + 1))
		[[ ${count} -eq 4 ]] && count=0

		[[ -z ${start_reading} ]] && [[ ${line} == *"maintained via ehooks"* ]] && start_reading=yes && continue
		[[ -z ${start_reading} ]] && continue
		[[ -n ${start_reading} ]] && [[ -z ${line} ]] && continue
		[[ -n ${start_reading} ]] && [[ ${line} == "#"* ]] && break
		echo "${line}" > /tmp/"${tmp_um}"

		for x in "${akwords[@]}"; do
			slot=$(get_slot "${x}")
			[[ -n ${slot} ]] && slot=":${slot}"
			[[ ${line} == ">"${x%${slot}}*${slot} ]] && echo "${x}" > /tmp/"${tmp_ak}"
		done
		if [[ -s /tmp/${tmp_ak} ]]; then
			update=$(equery -q l -p -F '$cpv|$mask2' "${line}" | grep "|~amd64$" | tail -1 | sed "s/|.*$//")
			touch /tmp/"${tmp_ak}"
		else
			update=$(equery -q l -p -F '$cpv|$mask2' "${line}" | grep "|amd64$" | tail -1 | sed "s/|.*$//")
		fi
		[[ -n ${update} ]] && updates+=( "${line}|${update}" )
	done < "${pmask}"
} 2>/dev/null

	## Remove temporary unmask file.
	rm /etc/portage/package.unmask/zzzz_"${tmp_um}" || exit 1
	rm /tmp/"${tmp_um}" || exit 1
	## Remove temporary accept_keywords file.
	rm /etc/portage/package.accept_keywords/zzzz_"${tmp_ak}" || exit 1
	rm /tmp/"${tmp_ak}" || exit 1

	printf "\b\b%s\n\n" "... done!"

	if [[ ! -e ${pmask} ]]; then
		eerror "'gentoo-unity7.mask' file not found"
		echo
	elif [[ -z ${updates[@]} ]]; then
		einfo "No updates found"
		echo
	else
		# Remove duplicates.
		updates=( $(printf "%s\n" "${updates[@]}" | sort -u) )

		echo " * Updates available:"
		echo
		for x in "${updates[@]}"; do
			## Format: ">old_pkg:slot|new_pkg".
			old_pkg="${x%|*}"; old_pkg="${old_pkg#>}"; slot=$(get_slot "${old_pkg}"); old_pkg="${old_pkg%:*}"
			new_pkg="${x#*|}"
			echo " * Update to ${color_yellow}${new_pkg}${color_norm} (old pmask entry: ${color_bold}>${old_pkg}${color_norm})"
			printf "%s" " * Test command 'EHOOKS_PATH=${pmask%/*}/ehooks ebuild \$(portageq get_repo_path / gentoo)/${new_pkg%-[0-9]*}/${new_pkg#*/}.ebuild clean prepare clean'${color_blink}...${color_norm}"
			if EHOOKS_PATH="${pmask%/*}/ehooks" ebuild "${main_repo}/${new_pkg%-[0-9]*}/${new_pkg#*/}".ebuild clean prepare clean 1>/dev/null; then
				printf "\b\b\b%s\n" "... ${color_blue}[ ${color_green}passed ${color_blue}]${color_norm}"
				for y in "${majorver[@]}"; do
					if [[ ${new_pkg} == "${y}"* ]]; then
						z="${new_pkg#*${y#*/}-}"; z="${z%%.*}"; z=$((z + 1))
						new_pkg="${y}-${z}"
						break
					fi
				done
				if [[ -n ${slot} ]]; then
					old_pkg="${old_pkg}:${slot}"
					new_pkg="${new_pkg}:${slot}"
				fi
				sed -i "s|${old_pkg}$|${new_pkg}|" "${pmask}" 2>/dev/null \
					&& echo " ${color_green}*${color_norm} New pmask entry: >${new_pkg}... ${color_blue}[ ${color_green}updated ${color_blue}]${color_norm}" \
					|| echo " ${color_red}*${color_norm} New pmask entry: >${new_pkg}... ${color_blue}[ ${color_red}not updated ${color_blue}]${color_norm}"
			else
				printf "\b\b\b%s\n" "... ${color_blue}[ ${color_red}failed ${color_blue}]${color_norm}"
			fi
			echo
		done
	fi
}

download_sources() {
	for rls in ${stable} ${dev}; do
		for frls in "${rls}" "${rls}"-security "${rls}"-updates; do
			for rp in "${repos[@]}"; do
				filename="/tmp/gentoo-unity7-sources-${rp}-${frls}"
				[[ -f ${filename} ]] && [[ $(($(date -r "${filename}" "+%s") + 72000)) -gt $(date "+%s") ]] && continue
				printf "%s" "Downloading ${frls}/${rp} sources${color_blink}...${color_norm}"
				wget -q -T 30 http://archive.ubuntu.com/ubuntu/dists/${frls}/${rp}/source/Sources.gz -O "${filename}.gz" \
					&& printf "\b\b\b%s\n" "... done!" \
					|| printf "\b\b\b%s\n" "... ${color_red}failed!${color_norm}"
				chmod 666 "${filename}.gz" 2>/dev/null
				gunzip -qf "${filename}.gz" 2>/dev/null
				[[ -f ${filename} ]] && touch "${filename}"
				ctl=1
			done
		done
	done
	[[ -n ${ctl} ]] && echo && unset ctl
}

check_sources() {
	for rls in ${stable} ${dev}; do
		for frls in "${rls}" "${rls}"-security "${rls}"-updates; do
			for rp in "${repos[@]}"; do
				if [[ ! -f /tmp/gentoo-unity7-sources-${rp}-${frls} ]]; then
					echo "/tmp/gentoo-unity7-sources-${rp}-${frls}... ${color_red}file not found!${color_norm}"
					ctl=1
				fi
			done
		done
	done
	[[ -n ${ctl} ]] && return 1 || return 0
}

get_uvers() {
	local ver x y

	local -a result subdirs

	if [[ -n $@ ]]; then
		grep -Fq "gentoo-unity7" "$1"/profiles/repo_name 2>/dev/null && y="$1/" && shift
		for x in "$@"; do
			subdirs+=( $(get_subdirs "${y}" "${x}/*src_unpack.ehooks") )
		done
	fi

	[[ -z $@ ]] && subdirs=( $(get_subdirs "${y}" "*/*/*src_unpack.ehooks") )

	for x in "${subdirs[@]}"; do
		ver=$(grep -Eo -m 1 "uver=[^[:space:]]+" "${x}")
		[[ -n ${ver} ]] && result+=( "${x}|${ver#uver=}" );
	done
	echo "${result[@]}"
}

get_debian_archive() {
	local x

	local -a filenames=( $1.debian.tar.xz $1.debian.tar.gz )

	for x in "${filenames[@]}"; do
		[[ -z $2 ]] && [[ -r /tmp/ehooks-${USER}-${x} ]] && return
		wget -q -T 60 "https://launchpad.net/ubuntu/+archive/primary/+files/${x}" -O "/tmp/${2:-ehooks-${USER}-${x}}" && return
	done

	return 1
}

debian_changes() {
	local x="$1" && shift

	[[ $(type -P equery) != "/usr/bin/equery" ]] && echo && eerror "'equery' tool from 'app-portage/gentoolkit' package not found!" && echo && exit 1
	[[ $(type -P qlist) != "/usr/bin/qlist" ]] && echo && eerror "'qlist' tool from 'app-portage/portage-utils' package not found!" && echo && exit 1
	check_path "$1"

	local -a uvers=( $(get_uvers "$@") )

	if [[ -z ${uvers[@]} ]]; then
		[[ -n $@ ]] && eerror "No package found! Package name must be in format: \${CATEGORY}/\${PN}." || eerror "No package found."
		echo
		exit 1
	fi

	local -a result

	case ${x} in
		-b|--blake)
			printf "%s" "Looking for BLAKE2 checksum changes${color_blink}...${color_norm}"

			local pre_sed pn sum

			for x in "${uvers[@]}"; do
				## Format: "file|uver".
				pn="${x#*ehooks/}"; pn="${pn%/*}"
				if get_debian_archive "${x#*|}" "ehooks-${USER}-debian.tmp"; then
					sum=$(b2sum "/tmp/ehooks-${USER}-debian.tmp" | cut -d ' ' -f 1)
					pre_sed=$(b2sum "${x%|*}")
					sed -i -e "s/blake=[[:alnum:]]*/blake=${sum}/" "${x%|*}"
					[[ ${pre_sed} != $(b2sum "${x%|*}") ]] && result+=( " ${color_green}*${color_norm} ${pn}... ${color_blue}[ ${color_green}updated ${color_blue}]${color_norm}" )
				else
					result+=( " ${color_red}*${color_norm} ${pn}... ${color_blue}[ ${color_red}debian file not found${color_blue} ]${color_norm}" )
				fi
			done
			;;
		-c|--changes)
			download_sources
			check_sources || return 1

			local \
				rls frls rp

			printf "%s" "Looking for available version changes${color_blink}...${color_norm}"

			local ipn pn un utd uv

			local -a an auvers result

			for x in "${uvers[@]}"; do
				auvers=()
				un="${x#*|}"
				utd="${color_yellow}${un#*_}${color_norm}"
				for rls in ${stable} ${dev}; do
					for frls in "${rls}" "${rls}"-security "${rls}"-updates; do
						for rp in "${repos[@]}"; do
							uv=$(grep -A6 "Package: ${un%_*}$" /tmp/gentoo-unity7-sources-${rp}-${frls} | sed -n 's/^Version: \(.*\)/\1/p' | sed 's/[0-9]://g')
							if [[ -n ${uv} ]]; then
								[[ ${uv} != ${pn} ]] && [[ ${uv} != ${un#*_} ]] && auvers+=( "'${uv}'" ) && pn="${uv}"
								[[ ${uv} == ${un#*_} ]] && utd="${utd/${color_yellow}/${color_green}}"
							fi
						done
					done
				done

				pn="${x#*ehooks/}"; pn="${pn%/*}"
				if [[ -n ${auvers[@]} ]]; then
					ipn=$(equery -q l -p -F '$cpv|$mask2' "${pn}" | grep "|amd64$" | tail -1 | sed "s/|.*$//")
					if [[ -z ${ipn} ]]; then
						ipn=$(qlist -Iv "${pn}")
						[[ -z ${ipn} ]] \
							&& ipn="$(tput bold)${color_cyan}${pn}${color_norm}" \
							|| ipn="$(tput bold)${color_cyan}${ipn}${color_norm}"
						an[0]="$(tput bold)${color_cyan}[ package is masked ]${color_norm}"
					fi
					result+=( " * ${ipn}... local: ${utd} available: ${auvers[*]}" )
					get_debian_archive "${un}"
					[[ -e debian/patches/series ]] \
						&& tar --overwrite -xf "/tmp/ehooks-${USER}-${un}.debian.tar.xz" -C /tmp debian/patches/series --strip-components 2 --transform "s/series/ehooks-${USER}-series/" \
						|| touch "/tmp/ehooks-${USER}-series"
					auvers=( "${auvers[@]//\'}" )
					for uv in "${auvers[@]}"; do
						get_debian_archive "${un%_*}_${uv}"
						[[ -e debian/patches/series ]] \
							&& tar --overwrite -xf "/tmp/ehooks-${USER}-${un%_*}_${uv}.debian.tar.xz" -C /tmp debian/patches/series --strip-components 2 --transform "s/series/ehooks-${USER}-aseries/" \
							|| touch "/tmp/ehooks-${USER}-aseries"
						if [[ -n $(diff /tmp/ehooks-${USER}-series /tmp/ehooks-${USER}-aseries) ]]; then
							result[${#result[@]}-1]="${result[${#result[@]}-1]/\'${uv}\'/\'${color_red}${uv}${color_norm}\'}"
							an[2]="${color_red}[ debian/patches/series file differs from local ]${color_norm}"
						fi
					done
				fi
			done
			;;
	esac
	printf "\b\b\b%s\n\n" "... done!"

	if [[ -n "${result[@]}" ]]; then
		for x in "${result[@]}"; do
			printf "%s\n\n" "${x}"
		done
		[[ "${result[@]}" == *"${color_yellow}"* ]] && an[1]="${color_yellow}[ package is outdated ]${color_norm}"
		for x in "${an[@]}"; do
			printf "%s\n" "${x}"
		done
		[[ -n ${an[@]} ]] && echo
	else
		einfo "No changes found"
		echo
	fi
}

update_packages() {
	local \
		path

	[[ -z $1 ]] && path="${PWD}" || path="$1"
	check_path "${path}"

	printf "%s\n\n" "${color_blue}Overlay:${color_norm}"
	tput sc
	printf "%s" "Looking for updates ${indicator[0]}"

	packages=( $(find ${path} -type f -name *.ebuild | rev | cut -d "/" -f 2,3 | rev | sort -u) )

	for x in "${remove[@]}"; do
		packages=( ${packages[@]/${x}} )
	done

	for pkg in "${packages[@]}"; do
		printf "\b\b %s" "${indicator[${count}]}"
		count=$((count + 1))
		[[ ${count} -eq 4 ]] && count=0

		name=${pkg#*/}
		for rls in ${stable} ${dev}; do
			for frls in "${rls}"-updates "${rls}"-security "${rls}"; do
				for rp in "${repos[@]}"; do
					case ${name} in
						indicator-classicmenu)
							fixname="classicmenu-indicator"
							;;
						indicator-psensor)
							fixname="psensor"
							;;
						nemo-engrampa)
							fixname="nemo-fileroller"
							;;
						*)
							fixname=${name}
							;;
					esac
					upstr_ver=$(grep -A 4 -- "^Package: ${fixname}$" /tmp/gentoo-unity7-sources-${rp}-${frls} | grep "Version: " | cut -d " " -f 2)
					if [[ -n ${upstr_ver} ]]; then
						[[ ${rls} == ${stable} ]] && pattern="\"amd64\"" || pattern="\"~amd64\""
						if [[ ${pkg} == "dev-libs/libindicator" ]] || [[ ${pkg} == "dev-libs/libappindicator" ]]; then
							filename=$(grep -H -- "${pattern}" ${path}/${pkg}/*r2*.ebuild | cut -d ":" -f 1)
							[[ ${filename} == *".ebuild"*".ebuild"* ]] \
								|| filename=$(grep -H -- "${pattern}" ${path}/${pkg}/*r3*.ebuild | cut -d ":" -f 1)
						else
							filename=$(grep -H -- "${pattern}" ${path}/${pkg}/*.ebuild | cut -d ":" -f 1)
						fi
						if [[ ${filename} == *".ebuild"*".ebuild"* ]]; then
							printf "\b\b%s\n\n" "... error!"
							printf "%s\n\n" " ${color_red}*${color_norm} ${pkg}: multiple files with KEYWORDS=${pattern}"
							exit 1
						fi
						if [[ -n ${filename} ]]; then
							[[ -z $(grep -- "^UVER=" "${filename}") ]] && break 3
							lcl_ver="${filename#${path}/${pkg}/${name}-}"
							[[ ${lcl_ver} == *"-r"* ]] || continue
							lcl_ver="${lcl_ver%-r*}"
							x=$(grep -- "^UVER=" "${filename}" | cut -d '=' -f 2)
							lcl_ver+=${x}
							x=$(grep -- "^UREV=" "${filename}" | cut -d '=' -f 2)
							[[ -n ${x} ]] && lcl_ver+="-"
							lcl_ver+=${x}
							upstr_ver_prev="${upstr_ver#*:}"
						else
							[[ ${lcl_ver} == ${upstr_ver#*:} ]] && unset lcl_ver upstr_ver || unset lcl_ver
							[[ ${upstr_ver_prev} == ${upstr_ver#*:} ]] && unset upstr_ver
						fi
						[[ -z ${lcl_ver} ]] && [[ -z ${upstr_ver} ]] && continue
						[[ ${lcl_ver} == ${upstr_ver#*:} ]] && break 2
						ctl=1
						tput rc; tput el
						echo "Overlay:  ${pkg}-${color_yellow}${lcl_ver:-none}${color_norm} (${rls})"
						echo "Upstream: ${pkg}-${color_green}${upstr_ver#*:}${color_norm} (${rls})"
						echo
						tput sc
						printf "%s" "Looking for updates ${indicator[${count}]}"
					fi
				done
			done
		done
	done

	printf "\b\b%s\n\n" "... done!"
	if [[ -z ${ctl} ]]; then
		printf "%s\n\n" " ${color_green}*${color_norm} No updates found"
	fi
}

update_scopes() {
	local \
		x

	[[ -z $1 ]] && x="${PWD}" || x="$1"
	check_path "${x}"

	printf "%s\n\n" "${color_blue}Scopes:${color_norm}"
	tput sc
	printf "%s" "Looking for updates ${indicator[0]}"

	ebuilds=( $(find ${x} -type f -name "smart-scopes*.ebuild") )
	packages=( $(grep -- "^setvar " "${ebuilds[@]}" | cut -d " " -f 2 | sed -E 's/\t+/|/g' | sort -u) )
	for pkg in "${packages[@]}"; do
		printf "\b\b %s" "${indicator[${count}]}"
		count=$((count + 1))
		[[ ${count} -eq 4 ]] && count=0

		name="unity-scope-${pkg%%|*}"
		uver="${pkg#*|}"; uver="${uver%|*}"
		urev="${pkg##*|}"
		for rls in ${stable} ${dev}; do
			for frls in "${rls}" "${rls}"-security "${rls}"-updates; do
				upstr_ver=$(grep -A 4 "^Package: ${name}$" /tmp/gentoo-unity7-sources-${repos[1]}-${frls} | grep "Version: " | cut -d " " -f 2)
				upstr_ver="${upstr_ver#*:}"
				if [[ -n ${upstr_ver} ]]; then
					[[ ${rls} == ${stable} ]] && pattern="\"amd64\"" || pattern="\"~amd64\""
					filename=$(grep -H -- "${pattern}" "${ebuilds[@]}" | cut -d ":" -f 1)
					if [[ ${filename} == *".ebuild"*".ebuild"* ]]; then
						printf "\b\b%s\n\n" "... error!"
						printf "%s\n\n" " ${color_red}*${color_norm} unity-scopes/smart-scopes: multiple files with KEYWORDS=${pattern}"
						exit 1
					fi
					if [[ -n ${filename} ]] && [[ $(grep -- "^setvar ${pkg%%|*}" "${filename}") == *"${uver}"*"${urev}"* ]]; then
						lcl_ver="${uver}-${urev}"
						upstr_ver_prev="${upstr_ver}"
					else
						[[ ${lcl_ver} == ${upstr_ver} ]] && unset lcl_ver upstr_ver || unset lcl_ver
						[[ ${upstr_ver_prev} == ${upstr_ver} ]] && unset upstr_ver
						[[ -n ${filename} ]] && [[ ${rls} == ${dev} ]] && continue
					fi
					[[ -z ${lcl_ver} ]] && [[ -z ${upstr_ver} ]] && continue
					[[ ${lcl_ver} == ${upstr_ver} ]] && continue
					ctl=1
					tput rc; tput el
					echo "Overlay:  ${name}-${color_yellow}${lcl_ver:-none}${color_norm} (${rls})"
					printf "%s" "Upstream: ${name}-${color_green}${upstr_ver}${color_norm} (${rls})"
					if [[ -n ${lcl_ver} ]]; then
						sed -i \
							-e "/^setvar ${pkg%%|*}/{s/${uver}/${upstr_ver%-*}/}" \
							-e "/^setvar ${pkg%%|*}/{s/${urev}/${upstr_ver#*-}/}" \
							"${filename}" 2>/dev/null \
							&& printf "%s\n" "... ${color_blue}[ ${color_green}updated ${color_blue}]${color_norm}" \
							|| printf "%s\n" "... ${color_blue}[ ${color_red}not updated ${color_blue}]${color_norm}"
					else
						printf "\n"
					fi
					echo
					tput sc
					printf "%s" "Looking for updates ${indicator[${count}]}"
				fi
			done
		done
	done

	printf "\b\b%s\n\n" "... done!"
	if [[ -z ${ctl} ]]; then
		printf "%s\n\n" " ${color_green}*${color_norm} No updates found"
	fi
}

update_languages() {
	local \
		x

	[[ -z $1 ]] && x="${PWD}" || x="$1"
	check_path "${x}"

	printf "%s\n\n" "${color_blue}Languages:${color_norm}"
	tput sc
	printf "%s" "Looking for updates ${indicator[0]}"
	ebuilds=( $(find ${x} -type f -name "unity-language-pack*.ebuild") )
	packages=( $(grep -- "^setvar " "${ebuilds[@]}" | sed -E 's/[ \t]+/|/g' | cut -d "|" -f 2,3,4,5 | sort -u) )
	for pkg in "${packages[@]}"; do
		printf "\b\b %s" "${indicator[${count}]}"
		count=$((count + 1))
		[[ ${count} -eq 4 ]] && count=0

		tag=$(echo "${pkg}" | cut -d "|" -f 4)
		[[ -z ${tag} ]] && tag="${pkg%%|*}"
		name="language-pack-gnome-${tag}-base"
		ver=$(echo "${pkg}" | cut -d "|" -f 2)
		gver=$(echo "${pkg}" | cut -d "|" -f 3)
		for rls in ${stable} ${dev}; do
			upstr_ver=$(grep -A 4 "^Package: ${name/-gnome}$" /tmp/gentoo-unity7-sources-${repos[0]}-${rls} | grep "Version: " | cut -d " " -f 2)
			upstr_gver=$(grep -A 4 "^Package: ${name}$" /tmp/gentoo-unity7-sources-${repos[0]}-${rls} | grep "Version: " | cut -d " " -f 2)
			upstr_ver="${upstr_ver#*:}"; upstr_gver="${upstr_gver#*:}"
			if [[ -n ${upstr_ver} || -n ${upstr_gver} ]]; then
				[[ ${rls} == ${stable} ]] && pattern="\"amd64\"" || pattern="\"~amd64\""
				filename=$(grep -H -- "${pattern}" "${ebuilds[@]}" | cut -d ":" -f 1)
				if [[ ${filename} == *".ebuild"*".ebuild"* ]]; then
					printf "\b\b%s\n\n" "... error!"
					printf "%s\n\n" " ${color_red}*${color_norm} unity-base/unity-language-pack: multiple files with KEYWORDS=${pattern}"
					exit 1
				fi
				if [[ -n ${filename} ]] && [[ $(grep -P -- "^setvar ${pkg%%|*}\t" "${filename}") == *"${ver} ${gver}"* ]]; then
					lcl_ver="${ver}"
					lcl_gver="${gver}"
					upstr_ver_prev="${upstr_ver}"
					upstr_gver_prev="${upstr_gver}"
				else
					[[ ${lcl_ver} == ${upstr_ver} ]] && unset lcl_ver upstr_ver || unset lcl_ver
					[[ ${lcl_gver} == ${upstr_gver} ]] && unset lcl_gver upstr_gver || unset lcl_gver
					[[ ${upstr_ver_prev} == ${upstr_ver} ]] && unset upstr_ver
					[[ ${upstr_gver_prev} == ${upstr_gver} ]] && unset upstr_gver
					[[ -n ${filename} ]] && [[ ${rls} == ${dev} ]] && continue
				fi
				[[ -z ${lcl_ver} ]] && [[ ${rls} == ${stable} ]] && continue
				[[ -z ${lcl_ver} ]] && [[ -z ${upstr_ver} ]] && [[ -z ${lcl_gver} ]] && [[ -z ${upstr_gver} ]] && continue
				[[ ${lcl_ver} == ${upstr_ver} ]] && [[ ${lcl_gver} == ${upstr_gver} ]] && continue
				[[ ${lcl_ver#*+} -gt ${upstr_ver#*+} && ${lcl_gver#*+} -gt ${upstr_gver#*+} ]] && continue
				ctl=1
				tput rc; tput el
				if [[ ${lcl_ver#*+} -lt ${upstr_ver#*+} ]]; then
					echo "Overlay:  ${name/-gnome}-${color_yellow}${lcl_ver:-new}${color_norm} (${rls})"
					printf "%s" "Upstream: ${name/-gnome}-${color_green}${upstr_ver}${color_norm} (${rls})"
					if [[ -n ${lcl_ver} ]]; then
						sed -i "/^setvar ${pkg%%|*}\t/{s/\t${lcl_ver}/\t${upstr_ver}/}" "${filename}" 2>/dev/null \
							&& printf "%s\n" "... ${color_blue}[ ${color_green}updated ${color_blue}]${color_norm}" \
							|| printf "%s\n" "... ${color_blue}[ ${color_red}not updated ${color_blue}]${color_norm}"
					else
						printf "\n"
					fi
				fi
				if [[ ${lcl_gver#*+} -lt ${upstr_gver#*+} ]]; then
					echo "Overlay:  ${name}-${color_yellow}${lcl_gver:-new}${color_norm} (${rls})"
					printf "%s" "Upstream: ${name}-${color_green}${upstr_gver}${color_norm} (${rls})"
					if [[ -n ${lcl_gver} ]]; then
						sed -i "/^setvar ${pkg%%|*}\t/{s/ ${lcl_gver}/ ${upstr_gver}/}" "${filename}" 2>/dev/null \
							&& printf "%s\n" "... ${color_blue}[ ${color_green}updated ${color_blue}]${color_norm}" \
							|| printf "%s\n" "... ${color_blue}[ ${color_red}not updated ${color_blue}]${color_norm}"
					else
						printf "\n"
					fi
				fi
				echo
				tput sc
				printf "%s" "Looking for updates ${indicator[${count}]}"
			fi
		done
	done
	printf "\b\b%s\n\n" "... done!"
	if [[ -z ${ctl} ]]; then
		printf "%s\n\n" " ${color_green}*${color_norm} No updates found"
	fi
}

case $1 in
	-b|--blake|-c|--changes)
		debian_changes "$@"
		;;
	-g|--generate)
		ehooks_changes
		;;
	-r|--reset)
		ehooks_changes "reset"
		;;
	-u|--update)
		download_sources
		check_sources || return 1
		portage_updates "$2"
		update_languages "$2"
		update_scopes "$2"
		update_packages "$2"
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
		echo "	${color_blue}-b${color_norm}, ${color_blue}--blake${color_norm} [${color_cyan}$(tput smul)repo path$(tput rmul)${color_norm}] [${color_cyan}$(tput smul)packages$(tput rmul)${color_norm}]"
		echo "		It updates BLAKE2 checksum of debian archive file in {pre,post}_src_unpack.ehooks."
		echo
		echo "	${color_blue}-c${color_norm}, ${color_blue}--changes${color_norm} [${color_cyan}$(tput smul)repo path$(tput rmul)${color_norm}] [${color_cyan}$(tput smul)packages$(tput rmul)${color_norm}]"
		echo "		It looks for available version changes of debian archive file."
		echo
		echo "	${color_blue}-g${color_norm}, ${color_blue}--generate${color_norm}"
		echo "		It looks for ehooks changes and generates emerge command needed to apply the changes."
		echo
		echo "	${color_blue}-r${color_norm}, ${color_blue}--reset${color_norm}"
		echo "		It looks for ehooks changes and set them as applied (it resets modification time)."
		echo
		echo "	${color_blue}-u${color_norm}, ${color_blue}--update${color_norm} [${color_cyan}$(tput smul)repo path$(tput rmul)${color_norm}]"
		echo "		It updates gentoo-unity7.mask version entries (it needs temporary access to /etc/portage/package.unmask), unity-base/unity-language-pack version entries, unity-scopes/smart-scopes version entries and it looks for available packages updates."
		echo
		exit 1
esac
