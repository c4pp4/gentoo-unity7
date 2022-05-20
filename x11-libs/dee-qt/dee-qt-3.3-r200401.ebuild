# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

UVER=+14.04.20140317
UREV=0ubuntu4

inherit cmake-utils ubuntu-versionator

DESCRIPTION="Qt binding and QML plugin for Dee for the Unity7 user interface"
HOMEPAGE="https://wiki.ubuntu.com/Unity"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"
RESTRICT="${RESTRICT} !test? ( test )"

COMMON_DEPEND="
	>=dev-libs/dee-1.0.0:=
	>=dev-qt/qtcore-5.12.2:5
	>=dev-qt/qtdeclarative-5.0.2
"
RDEPEND="${COMMON_DEPEND}
	>=dev-libs/glib-2.24.0:2
	>=sys-devel/gcc-4.9
	>=sys-libs/glibc-2.14
"
DEPEND="${COMMON_DEPEND}
	test? ( dev-util/dbus-test-runner )
"

S="${S}${UVER}"

src_prepare() {
	# Fix lib #
	sed -i "s:lib/::" CMakeLists.txt libdee-qt.pc.in || die

	ubuntu-versionator_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DWITHQT5=1
		-DCMAKE_LIBRARY_ARCHITECTURE=$(get_libdir)
		-DLIB_SUFFIX=""
	)
	cmake-utils_src_configure
}
