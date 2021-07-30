# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

URELEASE="hirsute"
inherit autotools eutils gnome2-utils ubuntu-versionator

UVER_PREFIX="+14.10.${PVR_MICRO}"

DESCRIPTION="Desktop service to integrate Telepathy with the messaging menu used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/telepathy-indicator"
SRC_URI="${UURL}/${MY_P}${UVER_PREFIX}.orig.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
RESTRICT="mirror"

DEPEND="dev-libs/libappindicator
	dev-libs/libdbusmenu[gtk3]
	dev-libs/libunity:=
	net-libs/telepathy-glib
	unity-indicators/indicator-messages"

S="${WORKDIR}/${PN}-${PV}${UVER_PREFIX}"

src_prepare() {
	ubuntu-versionator_src_prepare
	eautoreconf
}
