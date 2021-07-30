# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

URELEASE="hirsute"
inherit gnome2-utils ubuntu-versionator

DESCRIPTION="Graphical system load indicator for CPU, ram, etc. used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/indicator-multiload"
SRC_URI="${UURL}/${MY_P}.orig.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
RESTRICT="mirror"

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

src_install() {
	default
	mv "${ED%/}/usr/share/doc/${PN}" "${ED%/}/usr/share/doc/${PF}"
}

pkg_preinst() {
	gnome2_schemas_savelist
}

pkg_postinst() {
	gnome2_schemas_update
	ubuntu-versionator_pkg_postinst
}

pkg_postrm() {
	gnome2_schemas_update
}

