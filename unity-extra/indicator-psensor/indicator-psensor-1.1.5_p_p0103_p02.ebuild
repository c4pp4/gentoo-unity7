# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

URELEASE="hirsute"
inherit gnome2-utils ubuntu-versionator xdg-utils

MY_PN="psensor"

DESCRIPTION="Indicator for monitoring hardware temperature used by the Unity7 user interface"
HOMEPAGE="http://wpitchoune.net/psensor"
SRC_URI="${UURL}/${MY_PN}_${PV}.orig.tar.gz
	${UURL}/${MY_PN}_${PV}-${UVER}.debian.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="hddtemp nls"
RESTRICT="mirror"

DEPEND="dev-libs/glib:2
	>=dev-libs/json-c-0.12
	dev-libs/libappindicator
	dev-libs/libatasmart
	dev-libs/libunity
	gnome-base/dconf
	gnome-base/libgtop
	net-misc/curl
	sys-apps/lm-sensors
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libnotify
	x11-libs/libX11
	x11-libs/libXext
	hddtemp? ( app-admin/hddtemp )"

S="${WORKDIR}/${MY_PN}-${PV}"
MAKEOPTS="${MAKEOPTS} -j1"

src_prepare() {
	sed -i \
		-e "s/ayatana-appindicator/#ayatana-appindicator/" \
		"${WORKDIR}/debian/patches/series"
	ubuntu-versionator_src_prepare
}

src_configure() {
	econf \
		$(use_enable nls)
}

pkg_preinst() { gnome2_schemas_savelist; }

pkg_postinst() {
	gnome2_schemas_update
	xdg_icon_cache_update
	ubuntu-versionator_pkg_postinst
}

pkg_postrm() {
	gnome2_schemas_update
	xdg_icon_cache_update
}

