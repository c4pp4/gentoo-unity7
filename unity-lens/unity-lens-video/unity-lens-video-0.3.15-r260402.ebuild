# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
UBUNTU_EAUTORECONF="yes"

UVER=+16.04.20160212.1
UREV=0ubuntu6

inherit vala ubuntu-versionator

DESCRIPTION="Video lens for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/unity-lens-video"
S="${S}${UVER}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="test"
RESTRICT="!test? ( test )"

COMMON_DEPEND="
	>=dev-libs/dee-1.0.7:0=
	>=dev-libs/glib-2.37.3:2
	>=dev-libs/libgee-0.8.3:0.8
	>=dev-libs/libunity-7.0.9:0=
	>=dev-libs/libzeitgeist-0.3.14
	gnome-extra/cinnamon-desktop:0=
	x11-libs/gdk-pixbuf:2
"
RDEPEND="${COMMON_DEPEND}
	unity-lens/unity-lens-music
	|| (
		media-video/ffmpegthumbnailer[png]
		media-video/totem
	)
	|| (
		sys-apps/plocate
		sys-apps/mlocate
	)
"
DEPEND="${COMMON_DEPEND}"
BDEPEND="
	dev-util/intltool
	sys-devel/gettext
	virtual/pkgconfig
	$(vala_depend)
"

PATCHES=(
	"${FILESDIR}"/Remove-remote-video-support.patch
	"${FILESDIR}"/Use-Nemo-thumbnail-factory.patch
)

src_prepare() {
	# Wait for updatedb, a search runs locate right after it #
	# (the first search found nothing, the database didn't exist yet) #
	sed -i "/updatedb_bin/{s/async/sync/}" src/locate.vala || die
	grep -Fq 'GLib.Process.spawn_command_line_sync (@"$updatedb_bin' src/locate.vala || die

	ubuntu-versionator_src_prepare
}

src_test() {
	# GIO detects empty files as application/x-zerosize, not as video #
	local f
	for f in tests/unit/data/video{1..3}.{avi,mpg}; do
		printf "x" > "${f}" || die
	done

	default
}
