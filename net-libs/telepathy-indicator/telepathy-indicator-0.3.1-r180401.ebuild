# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
GNOME2_EAUTORECONF="yes"

UVER="+14.10.20140908"
UREV="0ubuntu2"

inherit gnome2 ubuntu-versionator

DESCRIPTION="Desktop service to integrate Telepathy with the messaging menu used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/telepathy-indicator"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-libs/libappindicator
	dev-libs/libdbusmenu[gtk3]
	dev-libs/libunity:=
	net-libs/telepathy-glib
	unity-indicators/indicator-messages"

S="${S}${UVER}"
