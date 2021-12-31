# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

UVER="+14.04.20140317"
UREV="0ubuntu4"

inherit cmake-utils ubuntu-versionator

DESCRIPTION="Qt binding and QML plugin for Dee for the Unity7 user interface"
HOMEPAGE="http://unity.ubuntu.com/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND=">=dev-libs/dee-1.2.7
	dev-libs/glib:2
	dev-qt/qtcore:5
	dev-qt/qtdeclarative:5"
DEPEND="${RDEPEND}"

S="${S}${UVER}"

src_prepare() {
	# Correct library installation path #
	sed \
		-e 's:LIBRARY DESTINATION lib/\${CMAKE_LIBRARY_ARCHITECTURE}:LIBRARY DESTINATION lib\${CMAKE_LIBRARY_ARCHITECTURE}:' \
		-e '/pkgconfig/{s/\/\${CMAKE_LIBRARY_ARCHITECTURE}/\${CMAKE_LIBRARY_ARCHITECTURE}\${LIB_SUFFIX}/}' \
		-i CMakeLists.txt
	sed \
		-e 's:lib/@CMAKE_LIBRARY_ARCHITECTURE@:lib@CMAKE_LIBRARY_ARCHITECTURE@@LIB_SUFFIX@:' \
		-i libdee-qt.pc.in
	ubuntu-versionator_src_prepare
}

src_configure() {
	mycmakeargs+=(-DWITHQT5=1
		-DCMAKE_INSTALL_PREFIX=/usr
		-DCMAKE_BUILD_TYPE=Release)
	cmake-utils_src_configure
}
