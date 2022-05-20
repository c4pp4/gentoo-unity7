# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{8..10} )

UVER=+bzr49+repack1
UREV=5

inherit cmake-utils python-single-r1 ubuntu-versionator

DESCRIPTION="Qt Bindings for python-dbusmock"
HOMEPAGE="https://launchpad.net/libqtdbusmock"
SRC_URI="${UURL}.orig.tar.xz
	${UURL}-${UREV}.debian.tar.xz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="coverage test"
REQUIRED_USE="${PYTHON_REQUIRED_USE} coverage? ( test )"
RESTRICT="${RESTRICT} !test? ( test )"

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
	>=dev-util/cmake-extras-1.5
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

S="${S}${UVER%+*}"

src_prepare() {
	# Enforce usage of the configured version of Python #
	sed -i \
		-e "s:python3:${EPYTHON}:" \
		tests/libqtdbusmock/TestDBusMock.cpp \
		src/libqtdbusmock/DBusMock.cpp || die

	# Make test optional #
	use test || sed -i '/add_subdirectory(tests)/d' CMakeLists.txt || die

	ubuntu-versionator_src_prepare
}

src_configure() {
	local mycmakeargs=( -Wno-dev )
	cmake-utils_src_configure
}
