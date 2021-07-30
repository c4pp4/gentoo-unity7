# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

URELEASE="hirsute"
inherit autotools eutils gnome2-utils ubuntu-versionator vala

DESCRIPTION="Blacklist configuration user interface for Zeitgeist"
HOMEPAGE="https://launchpad.net/activity-log-manager"
SRC_URI="${UURL}/${MY_P}.orig.tar.xz
	${UURL}/${MY_P}-${UVER}.debian.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
RESTRICT="mirror"

DEPEND="dev-libs/glib:2
	dev-libs/libgee:0.8
	dev-libs/libzeitgeist
	gnome-extra/zeitgeist
	sys-auth/polkit
	unity-base/unity-control-center
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/pango
	$(vala_depend)"

src_unpack() {
	default

	# Add translations #
	cd "${P%%_*}" || die
	unpack "${FILESDIR}"/translations-artful.tar.xz
}

src_prepare() {
	ubuntu-versionator_src_prepare
	vala_src_prepare
	export VALA_API_GEN="$VAPIGEN"
	eautoreconf
}

src_configure() {
	econf \
		--with-unity-ccpanel=yes \
		--with-ccpanel=no

	# Fix LOCALE_DIR prefix #
	sed -e "s:\"//:\"/usr/share/:g" \
		-i config.h
}

src_install() {
	emake DESTDIR="${ED}" install
	dodoc README NEWS INSTALL ChangeLog AUTHORS

	prune_libtool_files --modules
}

pkg_preinst() { gnome2_icon_savelist; }
pkg_postinst() { gnome2_icon_cache_update; ubuntu-versionator_pkg_postinst;}
pkg_postrm() { gnome2_icon_cache_update; }
