# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: ubuntu-versionator.eclass
# @MAINTAINER: c4pp4
# @AUTHOR: c4pp4
# @SUPPORTED_EAPIS: 8
# @BLURB: Provides phases for Ubuntu based packages.
# @DESCRIPTION:
# Exports portage base functions used by ebuilds written for packages using
# the gentoo-unity7 framework.

case ${EAPI} in
	8) ;;
	*) die "${ECLASS}: EAPI ${EAPI:-0} not supported" ;;
esac

# @ECLASS-VARIABLE: UBUNTU_EAUTORECONF
# @DEFAULT_UNSET
# @DESCRIPTION:
# Run eautoreconf
UBUNTU_EAUTORECONF=${UBUNTU_EAUTORECONF:-""}

[[ ${UBUNTU_EAUTORECONF} == "yes" ]] && inherit autotools

# Set base sane vala version for all packages requiring vala, override
# in ebuild if or when specific higher/lower versions are needed
VALA_MIN_API_VERSION=0.56
VALA_MAX_API_VERSION=0.56

# Ubuntu delete superceded release tarballs from their mirrors if the release
# is not Long Term Supported (LTS). Download tarballs from the always available
# Launchpad archive
UURL="https://launchpad.net/ubuntu/+archive/primary/+files/${PN}_${PV}${UVER}"

# Default variables
SRC_URI="${UURL}.orig.tar.gz"
RESTRICT="mirror"

# @FUNCTION: usub
# @DESCRIPTION:
# Generate a sub-slot from UVER and UREV values or use PV as a fallback.
usub() {
	local sub

	[[ -n ${UVER} ]] && sub="${UVER#+}-" || sub="${PV}-"
	[[ -n ${UREV} ]] && sub+="${UREV}" || sub="${sub%-}"
	echo "${sub}"
}

# @FUNCTION: einstalldocs
# @DESCRIPTION:
# Based on eutils.eclass' function. Install documentation using DOCS
# including COPYING* files. Inherit values if DOCS is declared.
einstalldocs() {
	debug-print-function ${FUNCNAME} "${@}"

	local \
		clog="changelog.ubuntu" \
		cright="copyright.ubuntu"

	if mv -n "${WORKDIR}"/debian/changelog "${clog}" 2>/dev/null; then
		mv -n "${WORKDIR}"/debian/copyright "${cright}" 2>/dev/null
	elif mv -n debian/changelog "${clog}" 2>/dev/null; then
		mv -n debian/copyright "${cright}" 2>/dev/null
	fi
	[[ -s ${cright} ]] || cright="COPYING* LICENSE*"

	local x
	local -aI DOCS
	for x in README* ChangeLog AUTHORS NEWS TODO CHANGES \
		THANKS BUGS FAQ CREDITS CHANGELOG \
		${clog} ${cright}; do
		if [[ -s ${x} ]] ; then
			DOCS+=( "${x}" )
		fi
	done

	if [[ -n ${DOCS[@]} ]]; then
		dodoc -r "${DOCS[@]}" || die
	fi

	return 0
}

# @FUNCTION: ubuntu-versionator_pkg_setup
# @DESCRIPTION:
# Check we have a valid profile set
# and apply python-single-r1_pkg_setup if declared.
ubuntu-versionator_pkg_setup() {
	debug-print-function ${FUNCNAME} "$@"

	[[ "$(readlink /etc/portage/make.profile)" == *"gentoo-unity7"* ]] \
		|| die "Invalid profile detected, please select gentoo-unity7 profile shown in 'eselect profile list'."

	declare -F font_pkg_setup 1>/dev/null && font_pkg_setup
	declare -F python-single-r1_pkg_setup 1>/dev/null && python-single-r1_pkg_setup
}

# @FUNCTION: ubuntu-versionator_src_unpack
# @DESCRIPTION:
# Relocate the sources in src_unpack as S=WORKDIR is deprecated
# for cmake.eclass (see b.g.o #889420).
ubuntu-versionator_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	mkdir -p ${S} || die
	cd ${S} || die
	default
}

# @FUNCTION: ubuntu-versionator_src_prepare
# @DESCRIPTION:
# Apply common src_prepare tasks such as patching and vala setting.
# Apply {xdg,gnome2,distutils-r1,cmake-utils}_src_prepare functions
# if declared or only apply default.
ubuntu-versionator_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	local \
		color_bold=$(tput bold) \
		color_norm=$(tput sgr0) \
		x

	# Apply Ubuntu diff file if present #
	local diff_file="${PN}_${PV}${UVER}-${UREV}.diff"
	[[ -f ${WORKDIR}/${diff_file} ]] && diff_file="${WORKDIR}/${diff_file}"
	if [[ -f ${diff_file} ]]; then
		echo "${color_bold}>>> Processing Ubuntu diff file${color_norm} ..."
		eapply "${diff_file}"
		echo "${color_bold}>>> Done.${color_norm}"
	fi

	# Apply Ubuntu patchset if one is present #
	local upatch_dir="debian/patches"
	local -a upatches
	[[ -f ${WORKDIR}/${upatch_dir}/series ]] && upatch_dir="${WORKDIR}/debian/patches"
	if [[ -f ${upatch_dir}/series ]]; then
		for x in $(grep -v \# "${upatch_dir}/series"); do
			upatches+=( "${upatch_dir}/${x}" )
		done
	fi
	if [[ -n ${upatches[@]} ]]; then
		echo "${color_bold}>>> Processing Ubuntu patchset${color_norm} ..."
		eapply "${upatches[@]}"
		echo "${color_bold}>>> Done.${color_norm}"
	fi

	if declare -F vala_setup 1>/dev/null; then
		vala_setup
		export VALA_API_GEN="${VAPIGEN}"
	fi

	if declare -F cmake_src_prepare 1>/dev/null; then
		cmake_src_prepare
	elif declare -F distutils-r1_src_prepare 1>/dev/null; then
		distutils-r1_src_prepare
	elif declare -F gnome2_src_prepare 1>/dev/null; then
		gnome2_src_prepare
	else
		default
	fi

	[[ ${UBUNTU_EAUTORECONF} == 'yes' ]] && eautoreconf
}

# @FUNCTION: ubuntu-versionator_pkg_postinst
# @DESCRIPTION:
# Apply {gnome2,xdg}_pkg_postinst function if declared and re-create
# bamf-2.index file of every package to capture all *.desktop files.
ubuntu-versionator_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	declare -F font_pkg_postinst 1>/dev/null && font_pkg_postinst

	if declare -F gnome2_pkg_postinst 1>/dev/null; then
		gnome2_pkg_postinst
	elif declare -F xdg_pkg_postinst 1>/dev/null; then
		xdg_pkg_postinst
	fi

	if [[ ${#XDG_ECLASS_DESKTOPFILES[@]} -gt 0 ]]; then
		[[ -x $(type -p bamf-index-create) ]] && bamf-index-create triggered
	fi
}

EXPORT_FUNCTIONS pkg_setup src_prepare pkg_postinst
