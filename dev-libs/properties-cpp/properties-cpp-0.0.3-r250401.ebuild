# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=2

inherit cmake ubuntu-versionator

DESCRIPTION="Simple convenience library for handling properties and signals in C++11"
HOMEPAGE="https://launchpad.net/properties-cpp"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.debian.tar.xz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="coverage doc test"
REQUIRED_USE="coverage? ( test )"
RESTRICT="!test? ( test )"

DEPEND="
	>=dev-build/cmake-extras-1.5

	test? (
		dev-cpp/gtest

		coverage? (
			dev-util/gcovr
			dev-util/lcov
		)
	)
"
BDEPEND="
	virtual/pkgconfig

	doc? (
		app-misc/rdfind
		app-misc/symlinks
		app-doc/doxygen[dot]
	)
"

MAKEOPTS="${MAKEOPTS} -j1"

src_prepare() {
	# Make test optional #
	use test || cmake_comment_add_subdirectory tests

	ubuntu-versionator_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_DOCDIR="/usr/share/doc/${PF}"
		-DPROPERTIES_CPP_ENABLE_DOC_GENERATION=$(usex doc ON OFF)
		-Wno-dev
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install

	if use doc; then
		# Taken from 'rules' #
		pushd "${ED}"/usr/share/doc/"${PF}"/html >/dev/null || die
			rdfind -makesymlinks true .
			symlinks -c .
			rm *.md5
			rm results.txt
		popd >/dev/null || die
	fi
}
