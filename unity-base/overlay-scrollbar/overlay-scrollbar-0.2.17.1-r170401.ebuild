# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
GNOME2_EAUTORECONF="yes"

UVER="+16.04.20151117"
UREV="0ubuntu2"

inherit gnome2 ubuntu-versionator

DESCRIPTION="Ayatana Scrollbars use an overlay to ensure scrollbars take up no active screen real-estate"
HOMEPAGE="http://launchpad.net/ayatana-scrollbar"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="gnome-base/dconf
	x11-libs/gtk+:2"

S="${S}${UVER}"

src_prepare() {
	# Install Xsession file into correct Gentoo path #
	sed -e 's:/X11/Xsession.d:/X11/xinit/xinitrc.d:g' \
		-i data/Makefile*

	ubuntu-versionator_src_prepare
}

src_configure() {
	econf --disable-static \
		--disable-tests
}

src_install() {
	default
	chmod +x "${ED%/}"/etc/X11/xinit/xinitrc.d/81overlay-scrollbar
	find "${ED}" -name '*.la' -delete || die
}
