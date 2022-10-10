# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
GNOME2_EAUTORECONF="yes"

UVER=+14.10.20140908
UREV=0ubuntu3

inherit gnome2 ubuntu-versionator

DESCRIPTION="Desktop service to integrate Telepathy with the messaging menu used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/telepathy-indicator"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"

COMMON_DEPEND="
	>=dev-libs/glib-2.31.8:2
	>=dev-libs/libunity-5.0.0:0=
	>=net-libs/telepathy-glib-0.19.9
	>=unity-indicators/indicator-messages-12.10.0
	>=x11-libs/gtk+-3.0.0:3
"
RDEPEND="${COMMON_DEPEND}
	>=sys-libs/glibc-2.4
	>=x11-libs/gdk-pixbuf-2.22.0:2
"
DEPEND="${COMMON_DEPEND}
	gnome-base/gnome-common
"
BDEPEND="dev-util/intltool"

S="${S}${UVER}"
