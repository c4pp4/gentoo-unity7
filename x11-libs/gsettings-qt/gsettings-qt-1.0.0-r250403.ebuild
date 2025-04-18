# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=4

inherit cmake ubuntu-versionator

DESCRIPTION="Qml bindings for GSettings."
HOMEPAGE="https://gitlab.com/ubports/development/core/gsettings-qt"
SRC_URI="${UURL}.orig.tar.bz2
	${UURL}-${UREV}.debian.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="qt6"
RESTRICT="test"

COMMON_DEPEND="
	>=dev-libs/glib-2.76.0:2

	qt6? (
		>=dev-qt/qtbase-6.8.0:6
		>=dev-qt/qtdeclarative-6.6.0:6
	)
	!qt6? (
		>=dev-qt/qtcore-5.15.1:5
		>=dev-qt/qtdeclarative-5.10.0:5
	)
"
RDEPEND="${COMMON_DEPEND}
	>=sys-devel/gcc-5
	>=sys-libs/glibc-2.14
"
DEPEND="${COMMON_DEPEND}
	>=dev-build/cmake-extras-1.8
	x11-apps/xauth
"
BDEPEND="virtual/pkgconfig"

S="${WORKDIR}/${PN}-v${PV}"

src_configure() {
	# Support new multilib layout #
	sed -i "s:/usr/lib:/usr/lib64:" GSettings/CMakeLists.txt

	local mycmakeargs=(
		-DENABLE_QT6=$(usex qt6 ON OFF)
		-Wno-dev
	)
	cmake_src_configure
}
