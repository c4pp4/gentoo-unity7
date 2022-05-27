# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
GNOME2_EAUTORECONF="yes"

UVER=
UREV=0ubuntu42

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
RESTRICT="${RESTRICT} test"

COMMON_DEPEND="
	>=dev-libs/glib-2.31.8:2
	>=dev-libs/libunity-5.0.0:0=
	>=gnome-base/gconf-3.2.5
	>=gnome-extra/evolution-data-server-3.17
	>=mail-client/evolution-3.36.0
	>=media-libs/libcanberra-0.2
	>=unity-indicators/indicator-messages-12.10.0
	>=x11-libs/gtk+-3.0.0:3
	>=x11-libs/libnotify-0.7.0
"
RDEPEND="${COMMON_DEPEND}
	>=dev-libs/libdbusmenu-0.4.2:=
	>=sys-libs/glibc-2.4
"
DEPEND="${COMMON_DEPEND}
	>=dev-libs/dbus-glib-0.7
	net-libs/libsoup:2.4
	>=sys-apps/dbus-1.0
	>=x11-libs/cairo-1.2.4
	>=x11-libs/pango-1.18.0
"

S="${WORKDIR}/${MY_PN}-${PV}"

src_configure() {
	local myeconfargs=(
		--disable-static
		--disable-schemas-install
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
