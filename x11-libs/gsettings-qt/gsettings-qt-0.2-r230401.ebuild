# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=5

inherit qmake-utils ubuntu-versionator virtualx

DESCRIPTION="Qml bindings for GSettings."
HOMEPAGE="https://gitlab.com/ubports/development/core/gsettings-qt"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.debian.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="test"

COMMON_DEPEND="
	>=dev-libs/glib-2.39.4:2
	>=dev-qt/qtcore-5.14.1:5
	>=dev-qt/qtdeclarative-5.10.0:5
"
RDEPEND="${COMMON_DEPEND}
	>=sys-devel/gcc-5
	>=sys-libs/glibc-2.14
"
DEPEND="${COMMON_DEPEND}
	x11-apps/xauth
"
BDEPEND="virtual/pkgconfig"

S="${WORKDIR}/${PN}-v${PV}"

src_prepare() {
	ubuntu-versionator_src_prepare

	# Disable tests #
	sed -i "/test/d" gsettings-qt.pro || die
}

src_configure() {
	eqmake5
}

src_install () {
	emake INSTALL_ROOT="${D}" install
	einstalldocs
}
