# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
GNOME2_EAUTORECONF="yes"
GNOME2_LA_PUNT="yes"

UVER=+20.10.20200617.2
UREV=0ubuntu1

inherit gnome2 ubuntu-versionator

DESCRIPTION="Indicator for application menus used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/indicator-appmenu"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

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

	tools? ( >=dev-libs/libdbusmenu-0.5.90[test] )
"
RDEPEND="${COMMON_DEPEND}
	gnome-base/dconf
	>=sys-libs/glibc-2.4
	unity-base/unity-gtk-module
	x11-libs/libX11
"
DEPEND="${COMMON_DEPEND}
	dev-libs/libappindicator:3
	gnome-base/gnome-common
	>=unity-indicators/indicator-application-0.4.90
"
BDEPEND="
	dev-util/gtk-doc
	dev-util/intltool
"

S="${WORKDIR}"
