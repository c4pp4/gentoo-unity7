# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
GNOME2_EAUTORECONF="yes"

UVER=""
UREV="0ubuntu27"

inherit gnome2 vala ubuntu-versionator

DESCRIPTION="Blacklist configuration user interface for Zeitgeist"
HOMEPAGE="https://launchpad.net/activity-log-manager"
SRC_URI="${UURL}.orig.tar.xz
	${UURL}-${UREV}.debian.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

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

src_configure() {
	econf \
		--with-unity-ccpanel=yes \
		--with-ccpanel=no

	# Fix LOCALE_DIR prefix #
	sed -e "s:\"//:\"/usr/share/:g" \
		-i config.h
}

src_install() {
	default
	find "${ED}" \( -name "*.a" -o -name "*.la" \) -delete || die

	# If a .desktop file does not have inline
	# translations, fall back to calling gettext
	local file
	for file in "${ED%/}"/usr/share/applications/*.desktop; do
		echo "X-GNOME-Gettext-Domain=${PN}" >> "${file}"
	done
}
