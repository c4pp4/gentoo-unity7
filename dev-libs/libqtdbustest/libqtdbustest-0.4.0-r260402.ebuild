# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{10..14} )

UVER=
UREV=3

inherit cmake python-single-r1 ubuntu-versionator

DESCRIPTION="Library to facilitate testing DBus interactions in Qt applications"
HOMEPAGE="https://launchpad.net/libqtdbustest"
SRC_URI="${UURL}.orig.tar.bz2
	${UURL}-${UREV}.debian.tar.xz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="coverage test"
REQUIRED_USE="coverage? ( test ) test? ( ${PYTHON_REQUIRED_USE} )"
RESTRICT="!test? ( test )"

COMMON_DEPEND="
	>=dev-qt/qtcore-5.15.1:5
	>=dev-qt/qtdbus-5.0.2:5
	>=dev-qt/qttest-5.0.2:5
"
RDEPEND="${COMMON_DEPEND}
	gnome-base/gvfs
	>=sys-devel/gcc-5.2
	>=sys-libs/glibc-2.14
"
DEPEND="${COMMON_DEPEND}
	>=dev-build/cmake-extras-1.5

	test? (
		dev-cpp/gtest

		coverage? (
			dev-util/gcovr
			dev-util/lcov
		)

		${PYTHON_DEPS}
		$(python_gen_cond_dep 'dev-python/python-dbusmock[${PYTHON_USEDEP}]')
	)
"
BDEPEND="
	sys-devel/gettext
	virtual/pkgconfig
"

src_prepare() {
	# Enforce usage of the configured version of Python #
	sed -i \
		-e "s:/usr/bin/python3:/usr/bin/${EPYTHON}:" \
		tests/libqtdbustest/Test{DBusTestRunner,QProcessDBusService}.cpp || die

	# Make test optional #
	use test || cmake_comment_add_subdirectory tests

	ubuntu-versionator_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DENABLE_QT6=OFF
		-Wno-dev
	)
	cmake_src_configure
}
