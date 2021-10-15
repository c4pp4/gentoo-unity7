# @ECLASS: ubuntu-versionator.eclass
# @MAINTAINER:
# Rick Harris <rickfharris@yahoo.com.au>
# @BLURB: Eclass to turn the example of package-version_p0_p0302 into 0ubuntu3.2
# @DESCRIPTION:
# This eclass simplifies manipulating $PVR for the purpose of creating
#  <patchlevel>ubuntu<revision> strings for Ubuntu based SRC_URIs

## Naming convention examples ##
# 0ubuntu0.12.10.3		= package-3.6.0_p_p0_p00121003
# 0ubuntu0.13.04.3		= package-3.6.0_p_p0_p00130403
# 0ubuntu3.2			= package-3.6.0_p_p0_p0302
# 1ubuntu5			= package-3.6.0_p_p1_p05
# 0ubuntu6			= package-3.6.0_p_p0_p06
# +14.10.20140915-1ubuntu2.2	= package-3.6.0_p20140915_p1_p0202 (14.10 is the Ubuntu release version taken from URELEASE)
#
## When upgrading <revision> from a floating point to a whole number, portage will see the upgrade as a downgrade ##
# Example: package-3.6.0_p_p0_p0101 (0ubuntu1.1) to package-3.6.0_p_p0_p02 (0ubuntu2)
# If this occurs, the ebuild should be named package-3.6.0a_p0_p02


inherit toolchain-funcs
EXPORT_FUNCTIONS pkg_setup pkg_postinst

#---------------------------------------------------------------------------------------------------------------------------------#
### GLOBAL ECLASS INHERIT DEFAULTS ##

## vala.eclass ##
# Set base sane vala version for all packages requiring vala, override in ebuild if or when specific higher/lower versions are needed #
export VALA_MIN_API_VERSION=${VALA_MIN_API_VERSION:=0.52}	# Needs to be >=${minimal_supported_minor_version} from vala.eclass
export VALA_MAX_API_VERSION=${VALA_MAX_API_VERSION:=0.52}
export VALA_USE_DEPEND="vapigen"

## Ubuntu delete superceded release tarballs from their mirrors if the release is not Long Term Supported (LTS) ##
# Download tarballs from the always available Launchpad archive #
UURL="https://launchpad.net/ubuntu/+archive/primary/+files"

#---------------------------------------------------------------------------------------------------------------------------------#

[[ ${URELEASE} == "impish"* ]] && UVER_RELEASE="21.10"
[[ ${URELEASE} == "jammy"* ]] && UVER_RELEASE="22.04"


PV="${PV%%[a-z]_p*}"	# For package-3.6.0a_p0_p02
PV="${PV%%[a-z]*}"	# For package-3.6.0a
PV="${PV%%_p*}"		# For package-3.6.0_p0_p02
PV="${PV%%_*}"		# For package-3.6.0_p_p02

MY_P="${PN}_${PV}"
S="${WORKDIR}/${PN}-${PV}"

OIFS="${IFS}"
IFS=p; read -ra PVR_ARRAY <<< "${PVR}"
IFS="${OIFS}"

## Micro version field ##
PVR_PL_MICRO="${PVR_ARRAY[1]}"
PVR_PL_MICRO="${PVR_PL_MICRO%*_}"
PVR_PL_MICRO="${PVR_PL_MICRO%%-r*}"     # Strip revision strings
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
PVR_MICRO="${PVR_PL_MICRO_tmp// /}"

## Major version field ##
PVR_PL_MAJOR="${PVR_ARRAY[2]}"
PVR_PL_MAJOR="${PVR_PL_MAJOR%*_}"
# Support floating point version numbers in major version field (eg. libnih-1.0.3_p0403_p01.ebuild becomes libnih-1.0.3-4.3ubuntu1)
if [ "${#PVR_PL_MAJOR}" -gt 1 ]; then
	PVR_PL_MAJOR="${PVR_PL_MAJOR%%-r*}"     # Strip revision strings
		char=2
		index=1
		strlength="${#PVR_PL_MAJOR}"
		while [ "${PVR_PL_MAJOR}" != "" ]; do   # Iterate through all chars loading every 2 chars into an array element
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
PVR_PL_MINOR="${PVR_PL_MINOR%%-r*}"	# Strip revision strings
	[[ -n "${strarray[@]}" ]] && unset 'strarray[@]'
	char=2
	index=1
	strlength="${#PVR_PL_MINOR}"
	while [ "${PVR_PL_MINOR}" != "" ]; do	# Iterate through all chars loading every 2 chars into an array element
		strtmp="${PVR_PL_MINOR:0:$char}"
		if [ "${strlength}" -ge 6 ]; then	# Don't strip zeros from 3rd number field, this is the Ubuntu OS release #
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

UVER="${PVR_PL_MAJOR}ubuntu${PVR_PL_MINOR}"

# @FUNCTION: ubuntu-versionator_pkg_setup
# @DESCRIPTION:
# Check we have a valid profile set and the correct
# masking in place for the overlay to work
ubuntu-versionator_pkg_setup() {
	debug-print-function ${FUNCNAME} "$@"

	[[ -n ${CURRENT_PROFILE} ]] && [[ ${CURRENT_PROFILE} == *"${REPO_ROOT}"* ]] \
		|| die "Invalid profile detected, please select gentoo-unity7 profile shown in 'eselect profile list'."
}

# @FUNCTION: ubuntu-versionator_src_prepare
# @DESCRIPTION:
# Apply common src_prepare tasks such as patching
ubuntu-versionator_src_prepare() {
	local \
		color_norm=$(tput sgr0) \
		color_bold=$(tput bold)

	debug-print-function ${FUNCNAME} "$@"

	# Apply Ubuntu patchset if one is present #
	[[ -f "${WORKDIR}/debian/patches/series" ]] && UPATCH_DIR="${WORKDIR}/debian/patches"
	[[ -f "debian/patches/series" ]] && UPATCH_DIR="debian/patches"
	if [ -d "${UPATCH_DIR}" ]; then
		for patch in $(grep -v \# "${UPATCH_DIR}/series"); do
			UBUNTU_PATCHES+=( "${UPATCH_DIR}/${patch}" )
		done
		[[ ${UBUNTU_PATCHES[@]} ]] && echo "${color_bold}>>> Processing Ubuntu patchset${color_norm} ..."
	fi
	# Many eclasses (cmake-utils,distutils-r1,qt5-build,xdg) apply their own 'default' command for EAPI=6 or 'epatch ${PATCHES[@]}' command for EAPI <6 so let them #
	#	'declare' checks to see if any of those functions are set/inherited and only apply 'default' if they are not
	[[ ${UBUNTU_PATCHES[@]} ]] && eapply "${UBUNTU_PATCHES[@]}" && echo "${color_bold}>>> Done.${color_norm}"
	[[ $(declare -Ff cmake-utils_src_prepare) ]] || \
	[[ $(declare -Ff distutils-r1_src_prepare) ]] || \
	[[ $(declare -Ff qt5-build_src_prepare) ]] || \
	[[ $(declare -Ff xdg_src_prepare) ]] \
		|| default
}

# @FUNCTION: ubuntu-versionator_pkg_postinst
# @DESCRIPTION:
# Re-create bamf.index
ubuntu-versionator_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	## Create a new bamf-2.index file at postinst stage of every package to capture all *.desktop files ##
	if [[ -x /usr/bin/bamf-index-create ]]; then
		einfo "Checking bamf-2.index"
		/usr/bin/bamf-index-create triggered
	fi
}
