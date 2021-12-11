#!/bin/bash

stable="impish"
dev="jammy"
sources="main universe"

color_blink=$(tput blink)
color_blue=$(tput bold; tput setaf 4)
color_cyan=$(tput setaf 6)
color_green=$(tput bold; tput setaf 2)
color_norm=$(tput sgr0)
color_red=$(tput bold; tput setaf 1)
color_yellow=$(tput bold; tput setaf 3)

count=1
indicator=( "|" "/" "-" "\\" )

download_sources() {
	for rls in ${stable} ${dev}; do
		for frls in "${rls}" "${rls}"-security "${rls}"-updates; do
			for src in ${sources}; do
				filename="/tmp/gentoo-unity7-${USER}-sources-${src}-${frls}"
				[[ -f ${filename} ]] && [[ $(($(date -r "${filename}" "+%s") + 86400)) -gt $(date "+%s") ]] && continue
				printf "%s" "Downloading ${frls}/${src} sources${color_blink}...${color_norm}"
				wget -q -T 60 http://archive.ubuntu.com/ubuntu/dists/${frls}/${src}/source/Sources.gz -O "${filename}.gz" \
					&& printf "\b\b\b%s\n" "... done!" \
					|| printf "\b\b\b%s\n" "... ${color_red}failed!${color_norm}"
				gunzip -qf "${filename}.gz" 2>/dev/null
				touch "${filename}"
				ctl=1
			done
		done
	done
	[[ -n ${ctl} ]] && echo
}

check_sources() {
	for rls in ${stable} ${dev}; do
		for frls in "${rls}" "${rls}"-security "${rls}"-updates; do
			for src in ${sources}; do
				if [[ ! -f /tmp/gentoo-unity7-${USER}-sources-${src}-${frls} ]]; then
					echo "/tmp/gentoo-unity7-${USER}-sources-${src}-${frls}... ${color_red}file not found!${color_norm}"
					ctl=1
				fi
			done
		done
	done
	[[ -n ${ctl} ]] && return 1 || return 0
}

update_packages() {
	remove=(
		app-eselect/eselect-lightdm
		dev-java/jayatana
		net-mail/mailnag
		unity-base/ubuntu-docs
		unity-base/unity-build-env
		unity-base/unity-language-pack
		unity-base/unity-meta
		unity-base/unity-settings
		unity-extra/ehooks
		unity-extra/indicator-netspeed
		unity-extra/indicator-privacy
		unity-indicators/unity-indicators-meta
		unity-lenses/unity-lens-meta
		unity-scopes/smart-scopes
		x11-plugins/mailnag-messagingmenu-plugin
	)

	tput sc
	printf "%s" "Looking for packages updates ${indicator[0]}"

	packages=( $(find -type f -name *.ebuild | cut -d "/" -f 2,3 | sort -u) )

	for x in "${remove[@]}"; do
		packages=( ${packages[@]/${x}} )
	done

	for pkg in "${packages[@]}"; do
		printf "\b\b %s" "${indicator[${count}]}"
		count=$((count + 1))
		[[ ${count} -eq 4 ]] && count=0

		name=${pkg#*/}
		for rls in ${stable} ${dev}; do
			for frls in "${rls}" "${rls}"-security "${rls}"-updates; do
				for src in ${sources}; do
					case ${name} in
						indicator-evolution)
							fixname="evolution-indicator"
							;;
						indicator-psensor)
							fixname="psensor"
							;;
						nm-applet)
							fixname="network-manager-applet"
							;;
						*)
							fixname=${name}
							;;
					esac
					upstr_ver=$(grep -A 4 -- "^Package: ${fixname}$" /tmp/gentoo-unity7-${USER}-sources-${src}-${frls} | grep "Version: " | cut -d " " -f 2)
					if [[ -n ${upstr_ver} ]]; then
						[[ ${rls} == ${stable} ]] && pattern="^KEYWORDS=" || pattern="^#KEYWORDS="
						filename=$(grep -H -- "${pattern}" ${pkg}/*.ebuild | cut -d ":" -f 1)
						if [[ -n ${filename} ]]; then
							[[ -z $(grep -- "^UVER=" "${filename}") ]] && break 3
							lcl_ver="${filename#${pkg}/${name}-}"
							[[ ${lcl_ver} == *"-r"* ]] || continue
							lcl_ver="${lcl_ver%-r*}"
							x=$(grep -- "^UVER=" "${filename}" | cut -d '"' -f 2)
							lcl_ver+=${x}
							x=$(grep -- "^UREV=" "${filename}" | cut -d '"' -f 2)
							[[ -n ${x} ]] && lcl_ver+="-"
							lcl_ver+=${x}
							upstr_ver_prev="${upstr_ver#*:}"
						else
							[[ ${lcl_ver} == ${upstr_ver#*:} ]] && unset lcl_ver upstr_ver || unset lcl_ver
							[[ ${upstr_ver_prev} == ${upstr_ver#*:} ]] && unset upstr_ver
						fi
						[[ -z ${lcl_ver} ]] && [[ -z ${upstr_ver} ]] && continue
						[[ ${lcl_ver} == ${upstr_ver#*:} ]] && continue
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
	tput sc
	printf "%s" "Looking for scopes updates ${indicator[0]}"

	ebuilds=( $(find -type f -name "smart-scopes*.ebuild") )
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
				for src in ${sources}; do
					upstr_ver=$(grep -A 4 "^Package: ${name}$" /tmp/gentoo-unity7-${USER}-sources-${src}-${frls} | grep "Version: " | cut -d " " -f 2)
					upstr_ver="${upstr_ver#*:}"
					if [[ -n ${upstr_ver} ]]; then
						[[ ${rls} == ${stable} ]] && pattern="^KEYWORDS=" || pattern="^#KEYWORDS="
						filename=$(grep -H -- "${pattern}" "${ebuilds[@]}" | cut -d ":" -f 1)
						if [[ ${filename} == *".ebuild"*".ebuild"* ]]; then
							printf "\b\b%s\n\n" "... error!"
							[[ ${rls} == ${stable} ]] \
								&& printf "%s\n\n" " ${color_red}*${color_norm} Multiple files with KEYWORDS" \
								|| printf "%s\n\n" " ${color_red}*${color_norm} Multiple files with missing KEYWORDS"
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
						echo "Upstream: ${name}-${color_green}${upstr_ver}${color_norm} (${rls})"
						echo
						[[ -n ${lcl_ver} ]] && sed -i \
							-e "/^setvar ${pkg%%|*}/{s/${uver}/${upstr_ver%-*}/}" \
							-e "/^setvar ${pkg%%|*}/{s/${urev}/${upstr_ver#*-}/}" \
							"${filename}"
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

update_languages() {
	tput sc
	printf "%s" "Looking for languages updates ${indicator[0]}"
	ebuilds=( $(find -type f -name "unity-language-pack*.ebuild") )
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
			for frls in "${rls}" "${rls}"-security "${rls}"-updates; do
				for src in ${sources}; do
					upstr_ver=$(grep -A 4 "^Package: ${name/-gnome}$" /tmp/gentoo-unity7-${USER}-sources-${src}-${frls} | grep "Version: " | cut -d " " -f 2)
					upstr_gver=$(grep -A 4 "^Package: ${name}$" /tmp/gentoo-unity7-${USER}-sources-${src}-${frls} | grep "Version: " | cut -d " " -f 2)
					upstr_ver="${upstr_ver#*:}"; upstr_gver="${upstr_gver#*:}"
					if [[ -n ${upstr_ver} ]]; then
						[[ ${rls} == ${stable} ]] && pattern="^KEYWORDS=" || pattern="^#KEYWORDS="
						filename=$(grep -H -- "${pattern}" "${ebuilds[@]}" | cut -d ":" -f 1)
						if [[ ${filename} == *".ebuild"*".ebuild"* ]]; then
							printf "\b\b%s\n\n" "... error!"
							[[ ${rls} == ${stable} ]] \
								&& printf "%s\n\n" " ${color_red}*${color_norm} Multiple files with KEYWORDS" \
								|| printf "%s\n\n" " ${color_red}*${color_norm} Multiple files with missing KEYWORDS"
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
						[[ -z ${lcl_ver} ]] && [[ -z ${upstr_ver} ]] && [[ -z ${lcl_gver} ]] && [[ -z ${upstr_gver} ]] && continue
						[[ ${lcl_ver} == ${upstr_ver} ]] && [[ ${lcl_gver} == ${upstr_gver} ]] && continue
						ctl=1
						tput rc; tput el
						if [[ ${lcl_ver} != ${upstr_ver} ]]; then
							echo "Overlay:  ${name/-gnome}-${color_yellow}${lcl_ver:-none}${color_norm} (${rls})"
							echo "Upstream: ${name/-gnome}-${color_green}${upstr_ver}${color_norm} (${rls})"
							[[ -n ${lcl_ver} ]] && sed -i "/^setvar ${pkg%%|*}\t/{s/${lcl_ver}/${upstr_ver}/}" "${filename}"
						fi
						if [[ ${lcl_gver} != ${upstr_gver} ]]; then
							echo "Overlay:  ${name}-${color_yellow}${lcl_gver:-none}${color_norm} (${rls})"
							echo "Upstream: ${name}-${color_green}${upstr_gver}${color_norm} (${rls})"
							[[ -n ${lcl_gver} ]] && sed -i "/^setvar ${pkg%%|*}\t/{s/${lcl_gver}/${upstr_gver}/}" "${filename}"
						fi
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

case $1 in
	-l|--languages)
		download_sources
		check_sources && update_languages
		;;
	-p|--packages)
		download_sources
		check_sources && update_packages
		;;
	-s|--scopes)
		download_sources
		check_sources && update_scopes
		;;
	*)
		echo "${color_blue}NAME${color_norm}"
		echo "	packages_version_control.sh"
		echo
		echo "${color_blue}SYNOPSIS${color_norm}"
		echo "	${color_blue}./packages_version_control.sh${color_norm} [${color_cyan}OPTION${color_norm}]"
		echo
		echo "${color_blue}DESCRIPTION${color_norm}"
		echo "	Packages version control tool."
		echo
		echo "${color_blue}OPTIONS${color_norm}"
		echo "	${color_blue}-l${color_norm}, ${color_blue}--languages${color_norm}"
		echo "		It updates unity-base/unity-language-pack version entries."
		echo
		echo "	${color_blue}-p${color_norm}, ${color_blue}--packages${color_norm}"
		echo "		It looks for available packages updates."
		echo
		echo "	${color_blue}-s${color_norm}, ${color_blue}--scopes${color_norm}"
		echo "		It updates unity-scopes/smart-scopes version entries."
		echo
		exit 1
esac
