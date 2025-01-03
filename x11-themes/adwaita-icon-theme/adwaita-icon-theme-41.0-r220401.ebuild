# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=1ubuntu1

inherit gnome2 ubuntu-versionator

DESCRIPTION="GNOME default icon theme"
HOMEPAGE="https://gitlab.gnome.org/GNOME/adwaita-icon-theme"
SRC_URI="${UURL}.orig.tar.xz"

LICENSE="
	|| ( LGPL-3 CC-BY-SA-3.0 )
	branding? ( CC-BY-SA-4.0 )
"
SLOT="0"
KEYWORDS="amd64"
IUSE="branding"
RESTRICT="binchecks strip"

# gtk+:3 is needed for build for the gtk-encode-symbolic-svg utility
# librsvg is needed for gtk-encode-symbolic-svg to be able to read the source SVG via its pixbuf loader and at runtime for rendering scalable icons shipped by the theme
DEPEND=">=x11-themes/hicolor-icon-theme-0.10"
RDEPEND="${DEPEND}
	>=gnome-base/librsvg-2.48:2
"
BDEPEND="
	>=gnome-base/librsvg-2.48:2
	sys-devel/gettext
	virtual/pkgconfig
	x11-libs/gtk+:3
"
src_unpack() {
	default
	use branding && unpack "${FILESDIR}"/tango-gentoo-v1.1.tar.gz
}

src_prepare() {
	if use branding; then
		for i in 16 22 24 32 48; do
			cp "${WORKDIR}"/tango-gentoo-v1.1/${i}x${i}/gentoo.png \
			"${S}"/Adwaita/${i}x${i}/places/start-here.png \
			|| die "Copying gentoo logos failed"
		done
	fi

	# Install cursors in the right place used in Gentoo
	sed -e 's:^\(cursordir.*\)icons\(.*\):\1cursors/xorg-x11\2:' \
		-i "${S}"/Makefile.am \
		-i "${S}"/Makefile.in || die

	ubuntu-versionator_src_prepare
}

src_configure() {
	gnome2_src_configure GTK_UPDATE_ICON_CACHE=$(type -P true)
}
