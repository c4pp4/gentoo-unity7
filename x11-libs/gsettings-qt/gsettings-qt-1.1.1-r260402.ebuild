# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=1

inherit cmake ubuntu-versionator

DESCRIPTION="Qml bindings for GSettings."
HOMEPAGE="https://gitlab.com/ubports/development/core/gsettings-qt"
SRC_URI="${UURL}.orig.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="qt5 qt6"
REQUIRED_USE="|| ( qt5 qt6 )"
RESTRICT="test"

COMMON_DEPEND="
	>=dev-libs/glib-2.76.0:2

	qt5? (
		>=dev-qt/qtcore-5.15.1:5
		>=dev-qt/qtdeclarative-5.10.0:5
	)
	qt6? (
		>=dev-qt/qtbase-6.8.0:6
		>=dev-qt/qtdeclarative-6.6.0:6
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

wrap_cmake() {
	BUILD_DIR="${WORKDIR}"/"${P}"_build-${1} cmake_${2}
}

src_configure() {
	# Support new multilib layout #
	sed -i "s:/usr/lib:/usr/lib64:" GSettings/CMakeLists.txt

	if use qt5; then
		local mycmakeargs=(
			-DENABLE_QT6=OFF
			-Wno-dev
		)
		wrap_cmake qt5 ${FUNCNAME}
	fi

	if use qt6; then
		local mycmakeargs=(
			-DENABLE_QT6=ON
			-Wno-dev
		)
		wrap_cmake qt6 ${FUNCNAME}
	fi
}

src_compile() {
	use qt5 && wrap_cmake qt5 ${FUNCNAME}
	use qt6 && wrap_cmake qt6 ${FUNCNAME}
}

src_install() {
	use qt5 && wrap_cmake qt5 ${FUNCNAME}
	use qt6 && wrap_cmake qt6 ${FUNCNAME}
}
