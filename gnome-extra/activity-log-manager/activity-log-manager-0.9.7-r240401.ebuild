# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
GNOME2_EAUTORECONF="yes"

UVER=
UREV=0ubuntu31

inherit gnome2 vala ubuntu-versionator

DESCRIPTION="Blacklist configuration user interface for Zeitgeist"
HOMEPAGE="https://launchpad.net/activity-log-manager"
SRC_URI="${UURL}.orig.tar.xz
	${UURL}-${UREV}.debian.tar.xz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="test"

COMMON_DEPEND="
	>=dev-libs/glib-2.43.2:2
	>=dev-libs/libgee-0.8.3:0.8
	>=gnome-extra/zeitgeist-0.9.9
	sys-auth/polkit
	>=unity-base/unity-control-center-14.04.0
	>=x11-libs/gtk+-3.5.12:3
"
RDEPEND="${COMMON_DEPEND}
	>=sys-libs/glibc-2.4
	>=x11-libs/cairo-1.2.4
	>=x11-libs/gdk-pixbuf-2.22.0:2
	>=x11-libs/pango-1.22.0
"
DEPEND="${COMMON_DEPEND}
	dev-libs/libgcrypt
	dev-util/desktop-file-utils

	$(vala_depend)
"
BDEPEND="
	>=dev-util/intltool-0.35.0
"

src_configure() {
	local myeconfargs=(
		--with-unity-ccpanel=yes
		--with-ccpanel=no
	)
	econf "${myeconfargs[@]}"

	# Fix LOCALE_DIR prefix #
	sed -i 's:"//:"/usr/share/:g' config.h
}

src_install() {
	default

	# If a .desktop file does not have inline #
	# translations, fall back to calling gettext #
	local x
	for x in "${ED}"/usr/share/applications/*.desktop; do
		echo "X-GNOME-Gettext-Domain=${PN}" >> "${x}"
	done

	find "${ED}" -name '*.la' -delete || die
}
