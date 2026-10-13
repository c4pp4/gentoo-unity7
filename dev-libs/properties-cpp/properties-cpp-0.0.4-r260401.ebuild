# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=1

inherit cmake ubuntu-versionator

DESCRIPTION="Simple convenience library for handling properties and signals in C++11"
HOMEPAGE="https://launchpad.net/properties-cpp"
SRC_URI="${UURL}.orig.tar.bz2
	${UURL}-${UREV}.debian.tar.xz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="coverage doc test"
REQUIRED_USE="coverage? ( test )"
RESTRICT="!test? ( test )"

DEPEND="test? ( dev-cpp/gtest )"
BDEPEND="
	>=dev-build/cmake-extras-1.5
	virtual/pkgconfig

	doc? ( app-text/doxygen[dot] )
	test? (
		coverage? (
			dev-util/gcovr
			dev-util/lcov
		)
	)
"

MAKEOPTS="${MAKEOPTS} -j1"

src_prepare() {
	# Fix libdir #
	sed -i "s:/lib$:/$(get_libdir):" data/properties-cpp.pc.in || die

	ubuntu-versionator_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING=$(usex test ON OFF)
		-DCMAKE_INSTALL_DOCDIR="/usr/share/doc/${PF}"
		-DPROPERTIES_CPP_ENABLE_DOC_GENERATION=$(usex doc ON OFF)
		-Wno-dev
	)
	CMAKE_BUILD_TYPE=$(usex coverage coverage Gentoo) cmake_src_configure
}

src_install() {
	cmake_src_install

	# Drop doxygen graph checksums #
	use doc && { rm -f "${ED}"/usr/share/doc/"${PF}"/html/*.md5 || die; }
}
