# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
UBUNTU_EAUTORECONF="yes"

UVER=+16.04
UREV=0ubuntu6

inherit vala ubuntu-versionator

DESCRIPTION="Music lens for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/unity-lens-music"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="test"
RESTRICT="!test? ( test )"

COMMON_DEPEND="
	>=dev-db/sqlite-3.7.7:3
	>=dev-libs/dee-1.2.5:0=
	>=dev-libs/glib-2.37.3:2
	>=dev-libs/libgee-0.8.3:0.8
	>=dev-libs/libunity-7.0.0:0=
	>=media-libs/gst-plugins-base-1.0.0:1.0
	>=media-libs/gstreamer-1.0.0:1.0
	>=sys-libs/tdb-1.2.7
"
RDEPEND="${COMMON_DEPEND}
	>=sys-libs/glibc-2.4
"
DEPEND="${COMMON_DEPEND}
	dev-libs/json-glib
	gnome-base/gnome-common
	x11-libs/libnotify

	$(vala_depend)
"
BDEPEND="virtual/pkgconfig"
PDEPEND="
	|| (
		media-sound/rhythmbox
		unity-scopes/smart-scopes[audacious]
		unity-scopes/smart-scopes[soundcloud]
	)
"

S="${S}${UVER}"

src_prepare() {
	# Fix .desktop file name #
	sed -i \
		-e "s/rhythmbox\.desktop/org.gnome.Rhythmbox3.desktop/" \
		src/daemon.vala || die

	ubuntu-versionator_src_prepare
}
