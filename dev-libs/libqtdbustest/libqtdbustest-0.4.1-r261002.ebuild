# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{12..15} )

UVER=
UREV=2

inherit cmake python-any-r1 ubuntu-versionator

DESCRIPTION="Library to facilitate testing DBus interactions in Qt applications"
HOMEPAGE="https://launchpad.net/libqtdbustest"
SRC_URI="${UURL}.orig.tar.bz2
	${UURL}-${UREV}.debian.tar.xz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="coverage test"
REQUIRED_USE="coverage? ( test )"
RESTRICT="!test? ( test )"

COMMON_DEPEND=">=dev-qt/qtbase-6.9.1:6[dbus]"
RDEPEND="${COMMON_DEPEND}
	sys-apps/dbus
"
DEPEND="${COMMON_DEPEND}
	test? ( dev-cpp/gtest )
"
BDEPEND="
	>=dev-build/cmake-extras-1.5
	virtual/pkgconfig

	test? (
		coverage? (
			dev-util/gcovr
			dev-util/lcov
		)

		${PYTHON_DEPS}
		$(python_gen_any_dep 'dev-python/python-dbusmock[${PYTHON_USEDEP}]')
	)
"

PATCHES=( "${FILESDIR}"/fix-qt6-compilation.patch )

python_check_deps() {
	use test || return 0
	python_has_version "dev-python/python-dbusmock[${PYTHON_USEDEP}]"
}

src_prepare() {
	if use test; then
		# Enforce usage of the configured version of Python #
		sed -i \
			-e "s:python3:${EPYTHON}:" \
			tests/libqtdbustest/TestDBusTestRunner.cpp \
			tests/libqtdbustest/TestQProcessDBusService.cpp || die
	else
		# Make test optional #
		cmake_comment_add_subdirectory tests
	fi

	# Fix coverage target name for Qt6 build #
	sed -i "/enable_coverage_report/,/)/{s/^\(\s*qtdbustest\)$/\1\${QT_SUFFIX}/}" CMakeLists.txt || die

	ubuntu-versionator_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DENABLE_QT6=ON
		-Wno-dev
	)
	CMAKE_BUILD_TYPE=$(usex coverage coverage Gentoo) cmake_src_configure
}
