# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{8..11} )

UVER=+17.04.20170404
UREV=0ubuntu5

inherit cmake python-single-r1 ubuntu-versionator

DESCRIPTION="API for Unity shell integration"
HOMEPAGE="https://launchpad.net/unity-api"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="doc pch test"
REQUIRED_USE="test? ( ${PYTHON_REQUIRED_USE} )"
RESTRICT="!test? ( test )"

COMMON_DEPEND="
	>=sys-devel/gcc-7
	>=dev-libs/glib-2.39.4:2
"
RDEPEND="${COMMON_DEPEND}
	>=sys-libs/glibc-2.33
"
DEPEND="${COMMON_DEPEND}
	dev-qt/qtdeclarative

	test? (
		dev-cpp/gtest
		dev-libs/libqtdbustest

		${PYTHON_DEPS}
	)
"
BDEPEND="
	sys-apps/lsb-release
	virtual/pkgconfig

	doc? ( app-doc/doxygen[dot] )
"

S="${WORKDIR}"

src_prepare() {
	if use doc; then
		# Fix docdir #
		sed -i "/DESTINATION/{s:doc:doc/${PF}:}" CMakeLists.txt || die
	else
		sed -i "/Doxygen/,+15 d" CMakeLists.txt || die
	fi

	use test && python_fix_shebang test

	# Fix libdir #
	sed -i \
		-e 's:lib/${CMAKE_LIBRARY_ARCHITECTURE}:${CMAKE_INSTALL_LIBDIR}:' \
		CMakeLists.txt || die

	ubuntu-versionator_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DNO_TESTS=$(usex !test ON OFF)
		-Duse_pch=$(usex pch ON OFF)
	)
	cmake_src_configure
}
