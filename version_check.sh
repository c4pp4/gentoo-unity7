#!/bin/bash

## Script to compare upstream versions of packages with versions in overlay tree ##

local_to_upstream_packnames() {
	## Overlay package names to upstream package names mapping ##
	if [ -n "`echo "${packbasename}" | grep 'indicator-evolution'`" ]; then treepackname="${packname}"; packname="evolution-indicator"
	elif [ -n "`echo "${packbasename}" | grep 'indicator-psensor'`" ]; then treepackname="${packname}"; packname="psensor"
	elif [ -n "`echo "${packbasename}" | grep 'nm-applet'`" ]; then treepackname="${packname}"; packname="network-manager-applet"
	elif [ -n "`echo "${packbasename}"`" ]; then treepackname="${packname}"
	fi
}

RELEASES="impish jammy"
SOURCES="main universe"

sources_download() {
	# Look for /tmp/Sources-* files older than 24 hours #
	#  If found then delete them ready for fresh ones to be fetched #
	#   Use 'find -mmin +1440' as 'find -mtime +1' has strange rounding where it won't return results until file is at least 2 days old #
	[[ -n $(find /tmp -type f -mmin +1440 2> /dev/null | grep Sources-) ]] && rm /tmp/Sources-* 2> /dev/null
	for get_release in ${RELEASES}; do
		for get_full_release in "${get_release}" "${get_release}"-security "${get_release}"-updates; do
			for source in ${SOURCES}; do
				if [ ! -f /tmp/Sources-${source}-${get_full_release} ]; then
					wget -q http://archive.ubuntu.com/ubuntu/dists/${get_full_release}/${source}/source/Sources.gz -O /tmp/Sources-${source}-${get_full_release}.gz || exit 1
					gunzip -q /tmp/Sources-${source}-${get_full_release}.gz || exit 1
					touch /tmp/Sources-${source}-${get_full_release}
				fi
			done
		done
	done
}

color_blink=$(tput blink)
color_green=$(tput bold; tput setaf 2)
color_norm=$(tput sgr0)
color_red=$(tput bold; tput setaf 1)

version_check() {
	local_to_upstream_packnames
	sources_download
	for ebuild in $(find -name "*.ebuild" 2> /dev/null | grep /"${catpack}"/); do
		URELEASE=
		pack="${ebuild}"
		packbasename=$(basename ${pack} | awk -F.ebuild '{print $1}')
		packname=$(echo ${catpack} | awk -F/ '{print $2}')
		local_version_check
		[ -z "${current}" ] && return || local_versions+=( "	${current}  ::  ${URELEASE}" )
	done
	local_versions_output=$(IFS=$'\n'; echo "${local_versions[*]}" | sort -k3)

	for get_release in ${RELEASES}; do
		for release in "${get_release}" "${get_release}"-security "${get_release}"-updates; do
			for ebuild in $(find -name "*.ebuild" 2> /dev/null | grep /"${catpack}"/ | sort); do
				pack="${ebuild}"
				packbasename=$(basename ${pack} | awk -F.ebuild '{print $1}')
				packname=$(echo ${catpack} | awk -F/ '{print $2}')
				local_to_upstream_packnames
				checkmsg_supress=1
				upstream_version_check ${release}
				checkmsg_supress=
				if [ -n "${upstream_version}" ]; then
					if [ -z "$(echo "${upstream_versions[@]}" | grep "${packname}-${upstream_version}")" ]; then
						# Only add new release element if not already present
						upstream_versions+=( "	${packname}-${upstream_version}  ::  ${release}" )
					fi
				else
					if [ -z "$(echo "${upstream_versions[@]}" | grep "${release}"$)" ] && \
						[ -n "${URELEASE}" ]; then
						upstream_versions+=( "		(none available)  ::  ${release}" )
					fi
				fi
			done
		done
	done
	index=0
	while [ "$index" -lt ${#upstream_versions[@]} ]; do
		upstream_versions_namespace_stripped=$(echo ${upstream_versions[$index]} | awk 'match($0, /-([0-9].*)/, a) {print a[1]}' | sed 's/[	]//g')
		local_versions_whitespace_stripped=$(echo ${local_versions[@]} | sed 's/[	]//g')
		compare_versions_stripped=$(echo ${local_versions_whitespace_stripped} | grep "${upstream_versions_namespace_stripped}")
		upstream_release=$(echo ${upstream_versions[$index]} | awk '{print $3}')
		if [ -z "${compare_versions_stripped}" ] && [ -z "$(echo ${upstream_versions[$index]} | grep "none available")" ] && [ -n "${URELEASE}" ]; then
			result+=( "Package ${catpack}" )
			result+=( "  Local versions:" )
			result+=( "${local_versions_output}" )
			result+=( "  Upstream versions:" )
			result+=( "${color_red}${upstream_versions[$index]}${color_norm}" )
			result+=( "" )
		fi
		((index++))
	done
	unset local_versions
	unset upstream_versions
	index=
	current=
	release=
}

local_version_check() {
	packbasename_saved="${packbasename}"    # Save off $packbasename for when uver() loops #
	. "${pack}" &> /dev/null
		uver
	. "${pack}" &> /dev/null
	if [ -n "${URELEASE}" ]; then
		if [ -n "${UVER}" ]; then
			packbasename=`echo "${packbasename}" | \
				sed -e 's:-r[0-9].*$::g' \
					-e 's:[a-z]$::'`	# Strip off trailing letter and revision suffixes from ${PV}
				current=`echo "${packbasename}${UVER_PREFIX}${UVER}${UVER_SUFFIX}"`
		else
			current=`echo "${packbasename}" | \
				sed -e 's:-r[0-9].*$::g' \
					-e 's:[a-z]$::'`	# Strip off trailing letter and revision suffixes from ${PV}
		fi
	fi
	packbasename="${packbasename_saved}"
	UVER=
	UVER_PREFIX=
	UVER_SUFFIX=
}

upstream_version_check() {
	upstream_version=
	if [ -n "$1" ]; then
		sources_download
		upstream_version=
		upstream_version=`grep -A6 "Package: ${packname}$" /tmp/Sources-main-$1 2> /dev/null | sed -n 's/^Version: \(.*\)/\1/p' | sed 's/[0-9]://g'`
		[[ -z "${upstream_version}" ]] && upstream_version=`grep -A6 "Package: ${packname}$" /tmp/Sources-universe-$1 2> /dev/null | sed -n 's/^Version: \(.*\)/\1/p' | sed 's/[0-9]://g'`
		[[ -z "${upstream_version}" ]] && upstream_version=`grep -A6 "Package: ${packname}$" /tmp/Sources-main-$1 2> /dev/null | sed -n 's/^Version: \(.*\)/\1/p' | sed 's/[0-9]://g'`
		[[ -z "${upstream_version}" ]] && upstream_version=`grep -A6 "Package: ${packname}$" /tmp/Sources-universe-$1 2> /dev/null | sed -n 's/^Version: \(.*\)/\1/p' | sed 's/[0-9]://g'`
	fi
}

uver() {
	[[ "${URELEASE}" == "impish"* ]] && UVER_RELEASE="21.10"
	[[ "${URELEASE}" == "jammy"* ]] && UVER_RELEASE="22.04"
	PVR=`echo "${packbasename}" | sed -e 's/.*-\([0-9]\)/\1/' -e 's:-r[0-9].*$::g'`
	PVR="_${PVR#*_}"

	packbasename=`echo "${packbasename}" | sed "s/${PVR}//"`
	packbasename=`echo "${packbasename}" | sed "s/[a-z]$//"`
	OIFS=${IFS}
	IFS=p; read -ra PVR_ARRAY <<< "${PVR}"
	IFS=${OIFS}

	## Micro version field ##
	PVR_PL_MICRO="${PVR_ARRAY[1]}"
	PVR_PL_MICRO="${PVR_PL_MICRO%*_}"
	if [ -n "${PVR_PL_MICRO}" ]; then
		[[ -n "${strarray[@]}" ]] && unset 'strarray[@]'
		char=2
		index=1
		strlength="${#PVR_PL_MICRO}"
		while [ "${PVR_PL_MICRO}" != "" ]; do
			strtmp="${PVR_PL_MICRO:0:$char}"
			if [ "${strlength}" -ge 10 ]; then      # Last field can be a floating point so strip off leading zero and add decimal point #
				if [ "${index}" = 5 ]; then
					strtmp=".${strtmp#0}"
				fi
			fi
			strarray+=( "${strtmp}" )
			PVR_PL_MICRO="${PVR_PL_MICRO:$char}"
			((index++))
		done
		PVR_PL_MICRO_tmp="${strarray[@]}"
		PVR_MICRO="${PVR_PL_MICRO_tmp// /}"     # Value gets sourced later from UVER variable in .ebuild #
	fi

	## Major version field ##
	PVR_PL_MAJOR="${PVR_ARRAY[2]}"
	PVR_PL_MAJOR="${PVR_PL_MAJOR%*_}"
	# Support floating point version numbers in major version field (eg. libnih-1.0.3_p0403_p01.ebuild becomes libnih-1.0.3-4.3ubuntu1)
	if [ "${#PVR_PL_MAJOR}" -gt 1 ]; then
		PVR_PL_MAJOR="${PVR_PL_MAJOR%%-r*}"	# Strip revision strings
		char=2
		index=1
		strlength="${#PVR_PL_MAJOR}"
		while [ "${PVR_PL_MAJOR}" != "" ]; do	# Iterate through all chars loading every 2 chars into an array element
			strtmp="${PVR_PL_MAJOR:0:$char}"
			strtmp="${strtmp#0}"
			strarray+=( "${strtmp}" )
			PVR_PL_MAJOR="${PVR_PL_MAJOR:$char}"
			((index++))
		done
		PVR_PL_MAJOR_tmp="${strarray[@]}"
		PVR_PL_MAJOR="${PVR_PL_MAJOR_tmp// /.}"
	fi

	## Minor version field ##
	PVR_PL_MINOR="${PVR_ARRAY[3]}"
	PVR_PL_MINOR="${PVR_PL_MINOR%*_}"
	[[ -n "${strarray[@]}" ]] && unset 'strarray[@]'
	char=2
	index=1
	strlength="${#PVR_PL_MINOR}"
	while [ "${PVR_PL_MINOR}" != "" ]; do
		strtmp="${PVR_PL_MINOR:0:$char}"
		if [ "${strlength}" -ge 6 ]; then       # Don't strip zeros from 3rd number field, this is the Ubuntu OS release #
			if [ "${index}" != 3 ]; then
				strtmp="${strtmp#0}"
			fi
		else
			strtmp="${strtmp#0}"
		fi
		strarray+=( "${strtmp}" )
		PVR_PL_MINOR="${PVR_PL_MINOR:$char}"
		((index++))
	done
	PVR_PL_MINOR_tmp="${strarray[@]}"
	PVR_PL_MINOR="${PVR_PL_MINOR_tmp// /.}"

	if [ "${packname}" = "linux" ]; then
		UVER="${PVR_PL_MAJOR}.${PVR_PL_MINOR}"
	else
		[[ -z ${UVER} ]] && \
			UVER="-${PVR_PL_MAJOR}ubuntu${PVR_PL_MINOR}"
	fi
	[[ -n "${strarray[@]}" ]] && unset 'strarray[@]'
}

printf "%s" "Looking for available version changes${color_blink}...${color_norm}"
for catpack in `find -name "*.ebuild" | awk -F/ '{print ( $(NF-2) )"/"( $(NF-1) )}' 2> /dev/null | sort -du | grep -Ev "eclass|metadata|profiles"`; do
	[[ ${catpack} == "unity-base/ubuntu-docs" ]] && continue
	[[ ${catpack} == "unity-extra/indicator-evolution" ]] && continue
	packname=`echo ${catpack} | awk -F/ '{print $2}'`
	version_check
done
printf "\b\b\b%s\n\n" "... done!"

if [[ -n "${result[@]}" ]]; then
	for x in "${result[@]}"; do
		printf "%s\n" "${x}"
	done
else
	echo " ${color_green}*${color_norm} No changes found"
	echo
fi
