#!/bin/bash

color_blink=$(tput blink)
color_blue=$(tput bold; tput setaf 4)
color_cyan=$(tput setaf 6)
color_green=$(tput bold; tput setaf 2)
color_norm=$(tput sgr0)
color_red=$(tput bold; tput setaf 1)
color_yellow=$(tput bold; tput setaf 3)

einfo() {
	echo " ${color_green}*${color_norm} $*"
}

ewarn() {
	echo " ${color_yellow}*${color_norm} $*"
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
	echo $(/usr/bin/portageq get_repo_path / gentoo-unity7)
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
	[[ $1 == *":"+([0-9.]) ]] && echo "${1##*:}" || echo ""
}

find_flag_changes() {
	local \
		reset="$1" \
		sys_db="/var/db/pkg/" \
		ts_file="/etc/ehooks/timestamps" \
		flag line n sys_date ts x

	local -a result

	while read -r line; do
		[[ ${line} == "##"* ]] && continue
		x="${line%%|*}"
		flag=$(echo "${line}" | cut -d "|" -f 2)
		portageq has_version / unity-extra/ehooks["${flag}"] \
			&& ts=$(echo "${line}" | cut -d "|" -f 3) \
			|| ts=$(echo "${line}" | cut -d "|" -f 4)
		slot=$(get_slot "${x}")

		pkg=( $(get_installed_packages "${x%:*}") )
		for n in "${pkg[@]}"; do
			## Try another package if slots differ.
			[[ -z ${slot} ]] || grep -Fqsx "${slot}" "${n}/SLOT" || continue

			## Try another package if modification time is newer or equal to ehooks USE flag change time.
			sys_date=$(date -r "${n}" "+%s")
			[[ ${sys_date} -ge ${ts} ]] && continue

			## Set USE flag change time equal to package's time when --reset option given.
			if [[ -n ${reset} ]]; then
				if portageq has_version / unity-extra/ehooks["${flag}"]; then
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
		f m n x

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
			## Try another package if slots differ.
			[[ -z ${slot} ]] || grep -Fqsx "${slot}" "${n}/SLOT" || continue

			## Try another package if modification time is newer or equal to ehooks (sub)directory time.
			sys_date=$(date -r "${n}" "+%s")
			[[ ${sys_date} -ge $(date -r "${x}" "+%s") ]] && continue

			## Try another package if ehooks_{require,use} flag is not declared.
			flags=( $(grep -Ehos "ehooks_(require|use)\s[A-Za-z0-9+_@-]+" "${x%%/files/*}/"*.ehooks) )
			if [[ -n ${flags[@]} ]]; then
				flags=( ${flags[@]/ehooks_require} ); flags=( ${flags[@]/ehooks_use} )
				for f in "${flags[@]}"; do
					portageq has_version / unity-extra/ehooks["${f}"] && break
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

	if [[ -n $1 ]] && ( [[ ! -w $(get_repo_root)/profiles/ehooks ]] || [[ ! -w /etc/ehooks/timestamps ]] ); then
		## Get ownership when write permission denied.
		result=( $(stat -c '%U:%G' $(get_repo_root)/profiles/ehooks) $(stat -c '%U:%G' /etc/ehooks/timestamps) )
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
		ewarn "Rebuild the packages affected by ehooks changes:"
		echo
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

find_portage_updates() {
	local \
		pmask="$1/profiles/unity-portage.pmask" \
		tmp_um=ehooks-punmask.tmp \
		tmp_ak=ehooks-paccept_keywords.tmp \
		line start_reading update x

	local -a result

	## Temporarily unmask packages maintained via ehooks.
	install -m 666 /dev/null /tmp/"${tmp_um}" || exit 1
	ln -fs /tmp/"${tmp_um}" /etc/portage/package.unmask/zzzz_"${tmp_um}" || exit 1

	for x in "${pmask[@]}"; do
		while read -r line; do
			[[ -z ${start_reading} ]] && [[ ${line} == *"maintained via ehooks"* ]] && start_reading=yes && continue
			[[ -z ${start_reading} ]] && continue
			[[ -n ${start_reading} ]] && [[ -z ${line} ]] && continue
			[[ -n ${start_reading} ]] && [[ ${line} == "#"* ]] && break
			echo "${line}" > /tmp/"${tmp_um}"

			if [[ ${line} == ">www-client/firefox"* ]]; then
				## Temporarily accept_keywords www-client/firefox.
				install -m 666 /dev/null /tmp/"${tmp_ak}" || exit 1
				ln -fs /tmp/"${tmp_ak}" /etc/portage/package.accept_keywords/zzzz_"${tmp_ak}" || exit 1
				echo "www-client/firefox::gentoo ~amd64" > /tmp/"${tmp_ak}"
			fi

			update=$(equery -q l -p -F '$cpv|$mask2' "${line}" | grep "\[32;01m" | tail -1 | sed "s/|.*$//")
			[[ -n ${update} ]] && result+=( "${line}|${update}" )

			if [[ ${line} == ">www-client/firefox"* ]]; then
				## Remove temporary www-client/firefox accept_keywords file.
				rm /etc/portage/package.accept_keywords/zzzz_"${tmp_ak}" || exit 1
				rm /tmp/"${tmp_ak}" || exit 1
			fi
		done < "${x}"
		start_reading=""
	done

	## Remove temporary unmask file.
	rm /etc/portage/package.unmask/zzzz_"${tmp_um}" || exit 1
	rm /tmp/"${tmp_um}" || exit 1

	[[ -z ${pmask[@]} ]] && echo "no pmask" || echo "${result[@]}"
}

portage_updates() {
	[[ $(type -P equery) != "/usr/bin/equery" ]] && echo && eerror "'equery' tool from 'app-portage/gentoolkit' package not found!" && echo && exit 1
	[[ ! -w /etc/portage/package.unmask ]] && echo && eerror "Permission denied to perform 'update'!" && echo && exit 1
	[[ -z $1 ]] && [[ ${PWD} == $(get_repo_root) ]] && echo && eerror "Don't run 'update' inside installed repo!" && echo && exit 1
	[[ -z $1 ]] && ! grep -Fq "gentoo-unity7" "${PWD}"/profiles/repo_name 2>/dev/null && echo && eerror "Run 'update' inside dev repo or set path!" && echo && exit 1
	[[ -n $1 ]] && ! grep -Fq "gentoo-unity7" "$1"/profiles/repo_name 2>/dev/null && echo && eerror "$1 is not dev repo path!" && echo && exit 1

	printf "%s" "Looking for gentoo main portage updates${color_blink}...${color_norm}"

	local \
		main_repo="$(/usr/bin/portageq get_repo_path / gentoo)" \
		new_pkg old_pkg x y

	[[ -z $1 ]] && x="${PWD}" || x="$1"
	local -a updates=( $(find_portage_updates "${x}") )

	printf "\b\b\b%s\n\n" "... done!"

	if [[ ${updates[@]} == "no pmask" ]]; then
		eerror "'unity-portage.pmask' file not found"
		echo
	elif [[ -z ${updates[@]} ]]; then
		einfo "No updates found"
		echo
	else
		local pmask="${x}/profiles/unity-portage.pmask"

		# Remove duplicates.
		updates=( $(printf "%s\n" "${updates[@]}" | sort -u) )

		echo " * Updates available:"
		echo
		for x in "${updates[@]}"; do
			## Format: ">old_pkg:slot|new_pkg".
			old_pkg="${x%|*}"; old_pkg="${old_pkg#>}"; old_pkg="${old_pkg%:*}"
			new_pkg="${x#*|}"
			echo " * Update from ${color_bold}${old_pkg}${color_norm} to ${color_yellow}${new_pkg}${color_norm}"
			printf "%s" " * Test command 'EHOOKS_PATH=${pmask%/*}/ehooks ebuild \$(portageq get_repo_path / gentoo)/${new_pkg%-[0-9]*}/${new_pkg#*/}.ebuild clean prepare'${color_blink}...${color_norm}"
			if EHOOKS_PATH="${pmask%/*}/ehooks" ebuild "${main_repo}/${new_pkg%-[0-9]*}/${new_pkg#*/}".ebuild clean prepare 1>/dev/null; then
				printf "\b\b\b%s\n" "... ${color_blue}[ ${color_green}passed ${color_blue}]${color_norm}"
				if [[ ${new_pkg} == "www-client/firefox"* ]]; then
					y="${new_pkg#*firefox-}"; y="${y%%.*}"; y=$((y + 1))
					new_pkg="www-client/firefox-${y}"
				fi
				if [[ ${new_pkg} == "mail-client/thunderbird"* ]]; then
					y="${new_pkg#*thunderbird-}"; y="${y%%.*}"; y=$((y + 1))
					new_pkg="mail-client/thunderbird-${y}"
				fi
				sed -i "s:${old_pkg}:${new_pkg}:" "${pmask}" 2>/dev/null \
					&& echo " ${color_green}*${color_norm} ${new_pkg%-[0-9]*}: '${pmask##*/}' entry... ${color_blue}[ ${color_green}updated ${color_blue}]${color_norm}" \
					|| echo " ${color_red}*${color_norm} ${new_pkg%-[0-9]*}: '${pmask##*/}' entry... ${color_blue}[ ${color_red}not updated ${color_blue}]${color_norm}"
			else
				printf "\b\b\b%s\n" "... ${color_blue}[ ${color_red}failed ${color_blue}]${color_norm}"
			fi
			echo
		done
	fi
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
		ver=$(grep -o -m 1 "uver=.*" "${x}")
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
	local x=$1 && shift

	[[ $(type -P equery) != "/usr/bin/equery" ]] && echo && eerror "'equery' tool from 'app-portage/gentoolkit' package not found!" && echo && exit 1
	[[ -z $1 ]] && [[ ${PWD} == $(get_repo_root) ]] && echo && eerror "Don't run 'check' inside installed repo!" && echo && exit 1
	[[ -z $1 ]] && ! grep -Fq "gentoo-unity7" "${PWD}"/profiles/repo_name 2>/dev/null && echo && eerror "Run 'check' inside dev repo or set path!" && echo && exit 1
	[[ -n $1 ]] && ! grep -Fq "gentoo-unity7" "${PWD}"/profiles/repo_name 2>/dev/null && ! grep -Fq "gentoo-unity7" "$1"/profiles/repo_name 2>/dev/null && echo && eerror "Dev repo path not found!" && echo && exit 1

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
			local \
				stable="jammy" \
				dev="kinetic" \
				rls frls rp

			local -a \
				repos=(
					main
					universe
				)

			for rls in ${stable} ${dev}; do
				for frls in "${rls}" "${rls}"-security "${rls}"-updates; do
					for rp in "${repos[@]}"; do
						filename="/tmp/ehooks-${USER}-sources-${rp}-${frls}"
						[[ -f ${filename} ]] && [[ $(($(date -r "${filename}" "+%s") + 72000)) -gt $(date "+%s") ]] && continue
						printf "%s" "Downloading ${frls}/${rp} sources${color_blink}...${color_norm}"
						wget -q -T 60 http://archive.ubuntu.com/ubuntu/dists/${frls}/${rp}/source/Sources.gz -O "${filename}.gz" \
							&& printf "\b\b\b%s\n" "... done!" \
							|| printf "\b\b\b%s\n" "... ${color_red}failed!${color_norm}"
						gunzip -qf "${filename}.gz" 2>/dev/null
						touch "${filename}"
						ctl=1
					done
				done
			done
			[[ -n ${ctl} ]] && echo && unset ctl

			for rls in ${stable} ${dev}; do
				for frls in "${rls}" "${rls}"-security "${rls}"-updates; do
					for rp in "${repos[@]}"; do
						filename="/tmp/ehooks-${USER}-sources-${rp}-${frls}"
						if [[ ! -f ${filename} ]]; then
							echo "${filename}... ${color_red}file not found!${color_norm}"
							ctl=1
						fi
					done
				done
			done
			[[ -n ${ctl} ]] && return 1

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
							uv=$(grep -A6 "Package: ${un%_*}$" /tmp/ehooks-${USER}-sources-${rp}-${frls} | sed -n 's/^Version: \(.*\)/\1/p' | sed 's/[0-9]://g')
							[[ -n ${uv} ]] && [[ ${uv} != ${pn} ]] && [[ ${uv} != ${un#*_} ]] && auvers+=( "'${uv}'" ) && pn="${uv}"
							[[ ${uv} == ${un#*_} ]] && utd="${utd/${color_yellow}/${color_green}}" || an[1]="${color_yellow}[ package is outdated ]${color_norm}"
						done
					done
				done

				pn="${x#*ehooks/}"; pn="${pn%/*}"
				if [[ -n ${auvers[@]} ]]; then
					ipn=$(equery -q l -p -F '$cpv|$mask2' "${pn}" | grep "\[32;01m" | tail -1 | sed "s/|.*$//")
					if [[ -z ${ipn} ]]; then
						ipn=$(qlist -Iv "${pn}")
						[[ -z ${ipn} ]] \
							&& ipn="$(tput bold)${color_cyan}${pn}${color_norm}" \
							|| ipn="$(tput bold)${color_cyan}${ipn}${color_norm}"
						an[0]="$(tput bold)${color_cyan}[ package is masked ]${color_norm}"
					fi
					result+=( " * ${ipn}... local: ${utd} available: ${auvers[*]}" )
					get_debian_archive "${un}"
					tar --overwrite -xf "/tmp/ehooks-${USER}-${un}.debian.tar.xz" -C /tmp debian/patches/series --strip-components 2 --transform "s/series/ehooks-${USER}-series/"
					auvers=( "${auvers[@]//\'}" )
					for uv in "${auvers[@]}"; do
						get_debian_archive "${un%_*}_${uv}"
						tar --overwrite -xf "/tmp/ehooks-${USER}-${un%_*}_${uv}.debian.tar.xz" -C /tmp debian/patches/series --strip-components 2 --transform "s/series/ehooks-${USER}-aseries/"
						if [[ -n $(diff /tmp/ehooks-${USER}-series /tmp/ehooks-${USER}-aseries) ]]; then
							result[${#result[@]}-1]="${result[${#result[@]}-1]/${uv}/${color_red}${uv}${color_norm}}"
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
		for x in "${an[@]}"; do
			printf "%s\n" "${x}"
		done
		[[ -n ${an[@]} ]] && echo
	else
		einfo "No changes found"
		echo
	fi
}

case $1 in
	-g|--generate)
		ehooks_changes
		;;
	-r|--reset)
		ehooks_changes "reset"
		;;
	-u|--update)
		portage_updates "$2"
		;;
	-b|--blake|-c|--changes)
		debian_changes "$@"
		;;
	*)
		echo "${color_blue}NAME${color_norm}"
		echo "	ehooks_version_control.sh"
		echo
		echo "${color_blue}SYNOPSIS${color_norm}"
		echo "	${color_blue}ehooks${color_norm} [${color_cyan}OPTION${color_norm}]"
		echo
		echo "${color_blue}DESCRIPTION${color_norm}"
		echo "	ehooks version control tool."
		echo
		echo "	/usr/bin/${color_blue}ehooks${color_norm} is a symlink to gentoo-unity7/ehooks_version_control.sh script."
		echo
		echo "${color_blue}OPTIONS${color_norm}"
		echo "	${color_blue}-g${color_norm}, ${color_blue}--generate${color_norm}"
		echo "		It looks for ehooks changes and generates emerge command needed to apply the changes."
		echo
		echo "	${color_blue}-r${color_norm}, ${color_blue}--reset${color_norm}"
		echo "		It looks for ehooks changes and set them as applied (it resets modification time)."
		echo
		echo "	${color_blue}-u${color_norm}, ${color_blue}--update${color_norm} [${color_cyan}$(tput smul)repo path$(tput rmul)${color_norm}]"
		echo "		It looks for Gentoo tree updates and refreshes unity-portage.pmask version entries (it needs temporary access to /etc/portage/package.unmask)."
		echo
		echo "	${color_blue}-b${color_norm}, ${color_blue}--blake${color_norm} [${color_cyan}$(tput smul)repo path$(tput rmul)${color_norm}] [${color_cyan}$(tput smul)packages$(tput rmul)${color_norm}]"
		echo "		It updates BLAKE2 checksum of debian archive file in {pre,post}_src_unpack.ehooks."
		echo
		echo "	${color_blue}-c${color_norm}, ${color_blue}--changes${color_norm} [${color_cyan}$(tput smul)repo path$(tput rmul)${color_norm}] [${color_cyan}$(tput smul)packages$(tput rmul)${color_norm}]"
		echo "		It looks for available version changes of debian archive file."
		echo
		exit 1
esac
