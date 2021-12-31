# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

UVER=""
UREV="6"

inherit cmake-utils ubuntu-versionator

DESCRIPTION="Simple convenience library for handling properties and signals in C++11"
HOMEPAGE="https://launchpad.net/properties-cpp"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.debian.tar.xz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc test"

DEPEND="dev-libs/boost

	doc? ( app-doc/doxygen
		media-gfx/graphviz )
        test? ( >=dev-cpp/gtest-1.8.1 )"

MAKEOPTS="${MAKEOPTS} -j1"

src_prepare() {
	use doc || sed -i '/add_subdirectory(doc)/d' CMakeLists.txt
	use test || sed -i '/add_subdirectory(tests)/d' CMakeLists.txt
	ubuntu-versionator_src_prepare
}

src_configure() {
	use doc && local mycmakeargs=(
		-DCMAKE_INSTALL_DOCDIR="/usr/share/doc/${PF}"
	)
	cmake-utils_src_configure
}
