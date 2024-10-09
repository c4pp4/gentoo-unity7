# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{10..13} )

UVER=
UREV=2

inherit cmake python-single-r1 ubuntu-versionator

DESCRIPTION="Qt Bindings for python-dbusmock"
HOMEPAGE="https://launchpad.net/libqtdbusmock"
SRC_URI="${UURL}.orig.tar.gz
	${UURL}-${UREV}.debian.tar.xz"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="coverage test"
REQUIRED_USE="${PYTHON_REQUIRED_USE} coverage? ( test )"
RESTRICT="!test? ( test )"

COMMON_DEPEND="
	>=dev-libs/libqtdbustest-0.2[${PYTHON_SINGLE_USEDEP}]
	>=dev-qt/qtcore-5.15.1:5
	>=dev-qt/qtdbus-5.0.2:5
	dev-qt/qttest:5

	${PYTHON_DEPS}
	$(python_gen_cond_dep '>=dev-python/python-dbusmock-0.16[${PYTHON_USEDEP}]')
"
RDEPEND="${COMMON_DEPEND}
	>=sys-devel/gcc-4.1.1
	>=sys-libs/glibc-2.14
"
DEPEND="${COMMON_DEPEND}
	>=dev-build/cmake-extras-1.5
	net-misc/networkmanager

	test? (
		dev-cpp/gtest

		coverage? (
			dev-util/gcovr
			dev-util/lcov
		)
	)
"
BDEPEND="
	sys-devel/gettext
	virtual/pkgconfig
"

src_prepare() {
	# Enforce usage of the configured version of Python #
	sed -i \
		-e "s:python3:${EPYTHON}:" \
		tests/libqtdbusmock/TestDBusMock.cpp \
		src/libqtdbusmock/DBusMock.cpp || die

	# Make test optional #
	use test || sed -i \
		-e "/enable_testing()/d" \
		-e "/add_subdirectory(tests)/d" \
		CMakeLists.txt || die

	ubuntu-versionator_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-Wno-dev
	)
	cmake_src_configure
}
