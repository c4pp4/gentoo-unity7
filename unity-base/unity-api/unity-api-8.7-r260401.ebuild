# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=+17.04.20170404
UREV=0ubuntu10

inherit cmake ubuntu-versionator

DESCRIPTION="API for Unity shell integration"
HOMEPAGE="https://launchpad.net/unity-api"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="doc pch"
RESTRICT="test"

RDEPEND=">=dev-libs/glib-2.39.4:2"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig

	doc? ( app-text/doxygen[dot] )
"

src_unpack() {
	ubuntu-versionator_src_unpack
}

src_prepare() {
	if use doc; then
		# Fix docdir #
		sed -i "/share\/doc/{s:share/doc[^)]*:share/doc/${PF}/html:}" CMakeLists.txt || die
	else
		sed -i "/Doxygen/,+15 d" CMakeLists.txt || die
	fi

	# Fix build with CMake 4 #
	sed -i "/cmake_minimum_required/{s/2\.8\.10/3.10/}" CMakeLists.txt || die

	# Fix libdir #
	sed -i \
		-e 's:lib/${CMAKE_LIBRARY_ARCHITECTURE}:${CMAKE_INSTALL_LIBDIR}:' \
		CMakeLists.txt || die

	# Preprocessor fixes #
	sed -i '/#include <vector>/a #include <cstdint>' include/unity/util/FileIO.h || die

	ubuntu-versionator_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DNO_TESTS=ON
		-Duse_pch=$(usex pch ON OFF)
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install

	# Drop doxygen graph checksums #
	if use doc; then
		find "${ED}"/usr/share/doc/"${PF}"/html -name '*.md5' -delete || die
	fi
}
