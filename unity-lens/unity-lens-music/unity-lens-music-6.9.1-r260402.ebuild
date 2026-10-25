# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
UBUNTU_EAUTORECONF="yes"

UVER=+16.04
UREV=0ubuntu7

inherit vala ubuntu-versionator

DESCRIPTION="Music lens for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/unity-lens-music"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"
S="${S}${UVER}"

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
RDEPEND="${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND}
	dev-libs/json-glib
	x11-libs/libnotify
"
BDEPEND="
	dev-util/intltool
	sys-devel/gettext
	virtual/pkgconfig
	$(vala_depend)
"
PDEPEND="
	|| (
		media-sound/rhythmbox
		(
			media-sound/audacious
			unity-lens/unity-scope-extras[audacious]
		)
	)
"

PATCHES=(
	"${FILESDIR}"/Do-not-warn-about-missing-Rhythmbox-database.patch
	"${FILESDIR}"/Remove-Banshee-support.patch
)
