# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: ubuntu-versionator.eclass
# @MAINTAINER: c4pp4
# @AUTHOR: c4pp4
# @SUPPORTED_EAPIS: 8
# @BLURB: Provides phase functions for Ubuntu-based packages.
# @DESCRIPTION:
# Provides common phase functions for ebuilds using the gentoo-unity7
# framework.

case ${EAPI} in
	8) ;;
	*) die "${ECLASS}: EAPI ${EAPI:-0} is not supported." ;;
esac

# @ECLASS-VARIABLE: UBUNTU_EAUTORECONF
# @DEFAULT_UNSET
# @DESCRIPTION:
# Set to "yes" before inheriting this eclass to run eautoreconf in src_prepare.
UBUNTU_EAUTORECONF=${UBUNTU_EAUTORECONF:-""}

[[ ${UBUNTU_EAUTORECONF} == "yes" ]] && inherit autotools

# Pin the Vala API version for packages requiring Vala, so that a change of
# the vala.eclass default can't break overlay packages unexpectedly.
# To use a different version, set these variables in the ebuild after inherit.
VALA_MIN_API_VERSION=0.56
VALA_MAX_API_VERSION=0.56

# Superseded source tarballs from non-LTS Ubuntu releases may no longer be
# available on Ubuntu mirrors. Fetch them from the Launchpad archive instead.
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

# @FUNCTION: epreparedocs
# @DESCRIPTION:
# Append common documentation files (README*, ChangeLog, AUTHORS, NEWS,
# COPYING*, debian/changelog, debian/copyright, ...) found in the source
# tree to DOCS, respecting its array/string type.
epreparedocs() {
	if [[ $(declare -p DOCS 2>/dev/null) == "declare -a"* ]] && (( ${#DOCS[@]} == 0 )); then
		return
	fi

	local d src dst
	local -a found=()

	for d in README* ChangeLog AUTHORS NEWS TODO CHANGES \
		THANKS BUGS FAQ CREDITS CHANGELOG COPYING* LICENSE*; do
		[[ -s ${d} ]] && found+=( "${S}/${d}" )
	done

	for src in "${S}" "${WORKDIR}"; do
		for d in changelog copyright; do
			[[ -s ${src}/debian/${d} ]] || continue
			dst="${T}/debian.${d}"
			cp "${src}/debian/${d}" "${dst}" || die
			found+=( "${dst}" )
		done
	done

	for d in "${found[@]}"; do
		has "${d}" ${DOCS[*]} && continue
		if [[ $(declare -p DOCS 2>/dev/null) == "declare -a"* ]]; then
			DOCS+=( "${d}" )
		elif [[ -n ${DOCS+set} ]]; then
			DOCS+=" ${d}"
		else
			DOCS=( "${d}" )
		fi
	done
}

# @FUNCTION: ubuntu-versionator_pkg_setup
# @DESCRIPTION:
# Verify that the selected profile belongs to gentoo-unity7.
# Call font_pkg_setup, python-single-r1_pkg_setup and python-any-r1_pkg_setup
# if defined.
ubuntu-versionator_pkg_setup() {
	debug-print-function ${FUNCNAME} "$@"

	local profile_dir
	profile_dir=$(readlink -e "${PORTAGE_CONFIGROOT%/}/etc/portage/make.profile") \
		|| die "The selected profile could not be resolved."
	grep -Fqx -- "gentoo-unity7" "${profile_dir%/*/*/*/*/*}/repo_name" \
		|| die "The selected profile does not belong to gentoo-unity7. Please select a gentoo-unity7 profile from 'eselect profile list'."

	declare -F font_pkg_setup 1>/dev/null && font_pkg_setup
	declare -F python-single-r1_pkg_setup 1>/dev/null && python-single-r1_pkg_setup
	declare -F python-any-r1_pkg_setup 1>/dev/null && python-any-r1_pkg_setup
}

# @FUNCTION: ubuntu-versionator_src_unpack
# @DESCRIPTION:
# Unpack sources into ${S} to avoid using S=${WORKDIR} with cmake.eclass
# (see b.g.o #889420).
ubuntu-versionator_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	mkdir -p "${S}" || die
	cd "${S}" || die
	default
}

# @FUNCTION: ubuntu-versionator_src_prepare
# @DESCRIPTION:
# Perform common src_prepare tasks, including patching and Vala setup.
# Call the first available src_prepare function from cmake, distutils-r1,
# or gnome2, in that order; otherwise, call default. Append common
# documentation files.
ubuntu-versionator_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	local x

	# Apply the Ubuntu diff file if present.
	local diff_file="${PN}_${PV}${UVER}-${UREV}.diff"
	[[ -f ${WORKDIR}/${diff_file} ]] && diff_file="${WORKDIR}/${diff_file}"
	if [[ -f ${diff_file} ]]; then
		einfo "Processing the Ubuntu diff file:"
		eapply "${diff_file}"
	fi

	# Apply the Ubuntu patchset if present.
	local upatch_dir="debian/patches"
	local -a upatches
	[[ -f ${WORKDIR}/${upatch_dir}/series ]] && upatch_dir="${WORKDIR}/debian/patches"
	if [[ -f ${upatch_dir}/series ]]; then
		for x in $(grep -v \# "${upatch_dir}/series"); do
			upatches+=( "${upatch_dir}/${x}" )
		done
	fi
	if [[ -n ${upatches[@]} ]]; then
		einfo "Processing the Ubuntu patchset (${#upatches[@]} patch$( (( ${#upatches[@]} > 1 )) && echo es)):"
		eapply "${upatches[@]}"
		einfo "Finished processing the Ubuntu patchset."
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

	epreparedocs
}

# @FUNCTION: ubuntu-versionator_pkg_postinst
# @DESCRIPTION:
# Call font_pkg_postinst if defined, then gnome2_pkg_postinst or
# xdg_pkg_postinst, whichever is available.
# Rebuild the BAMF desktop file index when the package installs desktop
# files and bamf-index-create is available.
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
