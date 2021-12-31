# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

UVER="+16.04"
UREV="0ubuntu3"

inherit autotools ubuntu-versionator vala

DESCRIPTION="Music lens for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/unity-lens-music"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-db/sqlite:3
	dev-libs/dee:=
	dev-libs/glib:2
	dev-libs/json-glib
	dev-libs/libgee
	dev-libs/libunity:=
	gnome-base/gnome-menus:3
	media-libs/gstreamer:1.0
	media-libs/gst-plugins-base:1.0
	sys-libs/tdb
	unity-base/unity
	$(vala_depend)"
PDEPEND="|| ( media-sound/rhythmbox
		media-sound/banshee
		unity-scopes/smart-scopes[audacious]
		unity-scopes/smart-scopes[soundcloud] )"

S="${S}${UVER}"

PATCHES=( "${FILESDIR}/${PN}-fix-build-against-vala-0.48.patch" )

src_prepare() {
	ubuntu-versionator_src_prepare
	eautoreconf
}
