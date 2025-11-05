# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=+16.04.20160218
UREV=4

inherit cmake ubuntu-versionator

DESCRIPTION="Library providing Qt implementation of DBusMenu specification"
HOMEPAGE="https://launchpad.net/libdbusmenu-qt/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="test"

COMMON_DEPEND="
	dev-qt/qtcore:5
	dev-qt/qtdbus:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5
"
RDEPEND="${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND}"

S="${S}${UVER}"

PATCHES=( "${FILESDIR}"/${P}${UVER}-cmake{,4}.patch ) # bug 953018

src_prepare() {
	cmake_comment_add_subdirectory tools
	# tests fail due to missing connection to dbus
	cmake_comment_add_subdirectory tests

	ubuntu-versionator_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-Wno-dev
	)
	CMAKE_BUILD_TYPE="None" cmake_src_configure
}
