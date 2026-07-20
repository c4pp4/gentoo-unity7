# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=+16.04.20160218
UREV=5

inherit cmake ubuntu-versionator

DESCRIPTION="Library providing Qt implementation of DBusMenu specification"
HOMEPAGE="https://launchpad.net/libdbusmenu-qt/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE="doc test"
RESTRICT="!test? ( test )"

COMMON_DEPEND="dev-qt/qtbase:6[dbus,gui,widgets]"
RDEPEND="${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND}"
BDEPEND="
	doc? ( app-text/doxygen )
	test? (	x11-themes/adwaita-icon-theme )
"

S="${S}${UVER}"

PATCHES=( "${FILESDIR}"/Qt6-migration.patch )

src_prepare() {
	# Make test optional #
	use test || cmake_comment_add_subdirectory tests

	# Fix doc dir #
	if use doc; then
		sed -i \
			-e "/DESTINATION share\/doc/{s|\${QT_SUFFIX}-doc|qt-${PVR}/html|}" \
			CMakeLists.txt || die
	fi

	# Redundant #
	cmake_comment_add_subdirectory tools

	ubuntu-versionator_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DWITH_DOC=$(usex doc ON OFF)
	)
	CMAKE_BUILD_TYPE="None" cmake_src_configure
}

src_test() {
    local -x QT_QPA_PLATFORM=offscreen

    dbus-run-session -- \
        cmake --build "${BUILD_DIR}" --target check --verbose
}
