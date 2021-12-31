# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
GNOME2_EAUTORECONF="yes"

UVER=""
UREV="0ubuntu5"

inherit gnome2 ubuntu-versionator

DESCRIPTION="Graphical system load indicator for CPU, ram, etc. used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/indicator-multiload"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="gnome-extra/gnome-system-monitor"
DEPEND="${RDEPEND}
	dev-libs/glib:2
	dev-libs/libappindicator:=
	dev-libs/libdbusmenu:=
	dev-libs/libindicate[gtk,introspection]
	gnome-base/dconf
	gnome-base/libgtop
	x11-libs/cairo
	x11-libs/gtk+:3"

src_prepare() {
	ubuntu-versionator_src_prepare
	sed -i "/^multiloaddocdir =/{s/${PN}/${PF}/}" Makefile.in
}
