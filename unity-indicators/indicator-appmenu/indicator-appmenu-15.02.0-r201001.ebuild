# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
GNOME2_EAUTORECONF="yes"
GNOME2_LA_PUNT="yes"

UVER="+20.10.20200617.2"
UREV="0ubuntu1"

inherit gnome2 ubuntu-versionator

DESCRIPTION="Indicator for application menus used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/indicator-appmenu"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-libs/libdbusmenu:=
	dev-libs/libappindicator:3=
	unity-base/bamf:=
	x11-libs/gtk+:3
	x11-libs/libwnck:1
	x11-libs/libwnck:3"

S="${WORKDIR}"
