# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
GNOME2_EAUTORECONF="yes"

UVER=+16.04.20151117
UREV=0ubuntu2

inherit gnome2 ubuntu-versionator

DESCRIPTION="Ayatana Scrollbars use an overlay to ensure scrollbars take up no active screen real-estate"
HOMEPAGE="https://launchpad.net/overlay-scrollbar"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="test"

COMMON_DEPEND="
	>=dev-libs/glib-2.37.3:2
	>=x11-libs/cairo-1.10.0
	>=x11-libs/gtk+-2.24.26:2
"
RDEPEND="${COMMON_DEPEND}
	gnome-base/dconf
	>=sys-libs/glibc-2.4
	x11-libs/libX11
"
DEPEND="${COMMON_DEPEND}"

S="${S}${UVER}"

src_prepare() {
	# Install Xsession file into correct Gentoo path #
	sed -i 's:/X11/Xsession.d:/X11/xinit/xinitrc.d:g' data/Makefile.am || die

	ubuntu-versionator_src_prepare
}

src_configure() {
	local myeconfargs=(
		--disable-static
		--disable-tests
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default

	chmod +x "${ED}"/etc/X11/xinit/xinitrc.d/81overlay-scrollbar
	find "${ED}" -name '*.la' -delete || die
}
