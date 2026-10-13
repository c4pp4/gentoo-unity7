# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{12..15} )

UVER=
UREV=3

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
	>=dev-libs/libqtdbustest-0.4.1-r261001
	>=dev-qt/qtbase-6.10.2:6[dbus]
"
RDEPEND="${COMMON_DEPEND}
	${PYTHON_DEPS}
	$(python_gen_cond_dep '>=dev-python/python-dbusmock-0.16[${PYTHON_USEDEP}]')
"
DEPEND="${COMMON_DEPEND}
	net-misc/networkmanager

	test? ( dev-cpp/gtest )
"
BDEPEND="
	dev-build/cmake-extras
	virtual/pkgconfig

	test? (
		coverage? (
			dev-util/gcovr
			dev-util/lcov
		)

		${PYTHON_DEPS}
		$(python_gen_cond_dep '>=dev-python/python-dbusmock-0.16[${PYTHON_USEDEP}]')
	)
"

PATCHES=( "${FILESDIR}"/GenerateExportHeader-migration.patch )

src_prepare() {
	# Enforce usage of the configured version of Python #
	sed -i \
		-e "s:python3:${EPYTHON}:" \
		tests/libqtdbusmock/TestDBusMock.cpp \
		src/libqtdbusmock/DBusMock.cpp || die

	if use test; then
		# Don't truncate process list to ${COLUMNS} #
		sed -i 's:<< "--no-headers":<< "-ww" << "--no-headers":' \
			tests/libqtdbusmock/TestDBusMock.cpp || die
	else
		# Make test optional #
		cmake_comment_add_subdirectory tests
	fi

	ubuntu-versionator_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DENABLE_QT6=ON
		-Wno-dev
	)
	CMAKE_BUILD_TYPE=$(usex coverage coverage Gentoo) cmake_src_configure
}
