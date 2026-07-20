# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{10..14} )

UVER=
UREV=2

inherit cmake python-single-r1 ubuntu-versionator

DESCRIPTION="Qt Bindings for python-dbusmock"
HOMEPAGE="https://launchpad.net/libqtdbusmock"
SRC_URI="${UURL}.orig.tar.bz2
	${UURL}-${UREV}.debian.tar.xz"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="coverage test"
REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	coverage? ( test )
"
RESTRICT="!test? ( test )"

COMMON_DEPEND="
	>=dev-libs/libqtdbustest-0.4.0-r260402[${PYTHON_SINGLE_USEDEP}]
	>=dev-qt/qtbase-6.10.2:6[dbus]

	${PYTHON_DEPS}
	$(python_gen_cond_dep '>=dev-python/python-dbusmock-0.16[${PYTHON_USEDEP}]')
"
RDEPEND="${COMMON_DEPEND}
	>=sys-devel/gcc-4.1.1
	>=sys-libs/glibc-2.14
"
DEPEND="${COMMON_DEPEND}
	dev-build/cmake-extras
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

PATCHES=( "${FILESDIR}"/GenerateExportHeader-migration.patch )

src_prepare() {
	# Enforce usage of the configured version of Python #
	sed -i \
		-e "s:python3:${EPYTHON}:" \
		tests/libqtdbusmock/TestDBusMock.cpp \
		src/libqtdbusmock/DBusMock.cpp || die

	# Make test optional #
	use test || cmake_comment_add_subdirectory tests

	ubuntu-versionator_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DENABLE_QT6=ON
		-Wno-dev
	)
	cmake_src_configure
}
