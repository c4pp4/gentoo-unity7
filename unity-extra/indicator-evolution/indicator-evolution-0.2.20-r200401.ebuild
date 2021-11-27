# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
GNOME2_EAUTORECONF="yes"

UVER=""
UREV="0ubuntu42"

inherit gnome2 ubuntu-versionator
MY_PN="evolution-indicator"
UURL="${UURL%/*}/${MY_PN}_${PV}${UVER}"

DESCRIPTION="Indicator for the Evolution mail client used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/evolution-indicator"
SRC_URI="${UURL}.orig.tar.gz
	${UURL}-${UREV}.debian.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-libs/dee:=
	dev-libs/glib:2
	dev-libs/libdbusmenu:=
	dev-libs/libunity:=
	dev-libs/libappindicator
	dev-libs/libindicate[gtk,introspection]
	gnome-base/gconf
	gnome-extra/evolution-data-server
	gnome-extra/gtkhtml
	mail-client/evolution
	media-libs/libcanberra
	unity-indicators/indicator-messages
	x11-libs/libnotify"

S="${WORKDIR}/${MY_PN}-${PV}"

src_configure() {
	econf --disable-static \
		--disable-schemas-install
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
