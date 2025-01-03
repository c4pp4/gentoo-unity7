# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{10..13} )

UVER=
UREV=3build3

inherit cmake python-single-r1 ubuntu-versionator

DESCRIPTION="Library to facilitate testing DBus interactions in Qt applications"
HOMEPAGE="https://launchpad.net/libqtdbustest"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.debian.tar.xz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="amd64"
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
	sys-apps/dbus
	>=sys-devel/gcc-5.2
	>=sys-libs/glibc-2.14
"
DEPEND="${COMMON_DEPEND}
	>=dev-build/cmake-extras-1.5
	sys-apps/dbus

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
	if use test; then
		# Enforce usage of the configured version of Python #
		sed -i \
			-e "s:/usr/bin/python3:/usr/bin/${EPYTHON}:" \
			tests/libqtdbustest/Test{DBusTestRunner,QProcessDBusService}.cpp || die
	else
		# Make test optional #
		use test || sed -i \
			-e "/enable_testing()/d" \
			-e "/add_subdirectory(tests)/d" \
			CMakeLists.txt || die
	fi

	ubuntu-versionator_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-Wno-dev
	)
	cmake_src_configure
}
