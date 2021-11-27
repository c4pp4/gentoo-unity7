#!/bin/bash

stable="impish"
dev="jammy"
sources="main universe"

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

color_blink=$(tput blink)
color_blue=$(tput bold; tput setaf 4)
color_cyan=$(tput setaf 6)
color_green=$(tput bold; tput setaf 2)
color_norm=$(tput sgr0)
color_red=$(tput bold; tput setaf 1)
color_yellow=$(tput bold; tput setaf 3)

count=1
indicator=( "|" "/" "-" "\\" )

case $1 in
	"")
		for rls in ${stable} ${dev}; do
			for frls in "${rls}" "${rls}"-security "${rls}"-updates; do
				for src in ${sources}; do
					printf "%s" "Downloading ${frls}/${src} sources${color_blink}...${color_norm}"
					wget -q -T 60 http://archive.ubuntu.com/ubuntu/dists/${frls}/${src}/source/Sources.gz -O /tmp/gentoo-unity7-${USER}-sources-${src}-${frls}.gz && printf "\b\b\b%s\n" "... done!" || printf "\b\b\b%s\n" "... ${color_red}failed!${color_norm}"
					gunzip -qf /tmp/gentoo-unity7-${USER}-sources-${src}-${frls}.gz 2>/dev/null
				done
			done
		done
		echo
		;;
	-n|--no-download)
		;;
	*)
		echo "${color_blue}NAME${color_norm}"
		echo "	packages_version_check.sh"
		echo
		echo "${color_blue}SYNOPSIS${color_norm}"
		echo "	${color_blue}./packages_version_check.sh${color_norm} [${color_cyan}OPTION${color_norm}]"
		echo
		echo "${color_blue}DESCRIPTION${color_norm}"
		echo "	Packages version check tool."
		echo
		echo "${color_blue}OPTIONS${color_norm}"
		echo "	${color_blue}-n${color_norm}, ${color_blue}--no-download${color_norm}"
		echo "		Use already downloaded sources."
		echo
		exit 1
esac

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
[[ -n ${ctl} ]] && exit 1

tput sc
printf "%s" "Looking for updates ${indicator[0]}"
packages=( $(find -type f -name *.ebuild | cut -d "/" -f 2,3 | sort -u) )

for x in "${remove[@]}"; do
	packages=( ${packages[@]/${x}} )
done

for pkg in "${packages[@]}"; do
	[[ ${count} -eq 4 ]] && count=0
	printf "\b\b %s" "${indicator[${count}]}"
	count=$((count + 1))

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
				upstr_ver=$(grep -A 4 "^Package: ${fixname}$" /tmp/gentoo-unity7-${USER}-sources-${src}-${frls} | grep "Version: " | cut -d " " -f 2)
				if [[ -n ${upstr_ver} ]]; then
					[[ ${rls} == ${stable} ]] && pattern="^KEYWORDS=" || pattern="^#KEYWORDS="
					filename=$(grep -H "${pattern}" -- ${pkg}/*.ebuild | cut -d ":" -f 1)
					if [[ -n ${filename} ]]; then
						[[ -z $(grep "^UVER=" -- ${filename}) ]] && break 3
						lcl_ver="${filename#${pkg}/${name}-}"
						[[ ${lcl_ver} == *"-r"* ]] || continue
						lcl_ver="${lcl_ver%-r*}"
						x=$(grep "^UVER=" -- ${filename} | cut -d '"' -f 2)
						lcl_ver+=${x}
						x=$(grep "^UREV=" -- ${filename} | cut -d '"' -f 2)
						[[ -n ${x} ]] && lcl_ver+="-"
						lcl_ver+=${x}
					else
						[[ ${lcl_ver} == ${upstr_ver#*:} ]] && unset lcl_ver upstr_ver || unset lcl_ver
					fi
					[[ -z ${lcl_ver} ]] && [[ -z ${upstr_ver} ]] && continue
					[[ ${lcl_ver} == ${upstr_ver#*:} ]] && continue
					ctl=1
					tput rc; tput el
					echo "Overlay:  ${pkg}-${color_yellow}${lcl_ver:-none}${color_norm} (${rls})"
					echo "Upstream: ${pkg}-${color_green}${upstr_ver#*:}${color_norm} (${rls})"
					echo
					tput sc
					printf "%s" "Looking for updates ${indicator[0]}"
				fi
			done
		done
	done
done
printf "\b\b%s\n\n" "... done!"
if [[ -z ${ctl} ]]; then
	printf "%s\n\n" " ${color_green}*${color_norm} No updates found"
fi
