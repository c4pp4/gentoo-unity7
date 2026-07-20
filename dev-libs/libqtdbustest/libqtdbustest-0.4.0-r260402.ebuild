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
KEYWORDS="amd64"
IUSE="coverage test"
REQUIRED_USE="
	coverage? ( test )
	test? ( ${PYTHON_REQUIRED_USE} )
"
RESTRICT="!test? ( test )"

COMMON_DEPEND=">=dev-qt/qtbase-6.9.1:6[dbus]"
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

PATCHES=( "${FILESDIR}"/fix-qt6-compilation.patch )

src_prepare() {
	# Enforce usage of the configured version of Python #
	sed -i \
		-e "s:\"python3:\"${EPYTHON}:" \
		"${WORKDIR}"/debian/patches/0001-tests-Make-tests-portable-to-other-systems-than-gnu-.patch || die

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
