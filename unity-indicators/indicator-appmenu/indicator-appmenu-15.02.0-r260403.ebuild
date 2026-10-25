# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
GNOME2_EAUTORECONF="yes"
GNOME2_LA_PUNT="yes"

UVER=+20.10.20260311
UREV=0ubuntu1

inherit gnome2 ubuntu-versionator

DESCRIPTION="Indicator for application menus used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/indicator-appmenu"
SRC_URI="${UURL}-${UREV}.tar.gz"
S="${WORKDIR}/${PN}.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="tools"
RESTRICT="test"

COMMON_DEPEND="
	>=dev-libs/glib-2.41.1:2
	>=dev-libs/libdbusmenu-0.5.90[gtk3]
	>=dev-libs/libindicator-0.4.90:3
	>=unity-base/bamf-0.5.2:0=
	>=x11-libs/gtk+-3.5.12:3
	x11-libs/libX11

	tools? ( >=dev-libs/libdbusmenu-0.5.90[test] )
"
RDEPEND="${COMMON_DEPEND}
	gnome-base/dconf
	x11-misc/appmenu-gtk-module[gtk2]
"
DEPEND="${COMMON_DEPEND}
	tools? ( dev-libs/libappindicator:3 )
"
BDEPEND="
	dev-build/gtk-doc-am
	dev-util/intltool
	gnome-base/gnome-common
	virtual/pkgconfig
"

PATCHES=( "${FILESDIR}"/do-not-warn-about-windows-without-menus.patch )

src_prepare() {
	# ,: command not found #
	sed -i "/BUILD_CLI/{s/,$//}" configure.ac || die

	# Vala compiler not found or too old #
	sed -i "/AM_PROG_VALAC/d" configure.ac || die

	# have_dbusmenu-jsonloader=no: command not found #
	sed -i "s/have_dbusmenu-jsonloader/have_dbusmenu_jsonloader/" configure.ac || die
	! grep -Fq "have_dbusmenu-jsonloader" configure.ac || die

	ubuntu-versionator_src_prepare
}

src_configure() {
	gnome2_src_configure $(use_enable tools tests)
}
