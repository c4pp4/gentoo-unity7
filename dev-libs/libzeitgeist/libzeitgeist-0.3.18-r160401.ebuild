# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

UVER=""
UREV="1ubuntu3"

inherit autotools ubuntu-versionator

DESCRIPTION="Client library to interact with zeitgeist"
HOMEPAGE="https://launchpad.net/libzeitgeist/"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.debian.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="static-libs"

CDEPEND="dev-libs/glib:2"
RDEPEND="${CDEPEND}
	gnome-extra/zeitgeist"
DEPEND="${CDEPEND}
	dev-util/gtk-doc
	virtual/pkgconfig"

src_prepare() {
	ubuntu-versionator_src_prepare

	sed \
		-e "s:doc/libzeitgeist:doc/${PF}:" \
		-i Makefile.am || die

	eautoreconf
}
