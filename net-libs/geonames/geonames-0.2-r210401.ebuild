# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

UVER="+17.04.20170220"
UREV="0ubuntu4"

inherit autotools ubuntu-versionator

DESCRIPTION="Parse and query the geonames database dump"
HOMEPAGE="https://launchpad.net/geonames"
SRC_URI="${UURL}-${UREV}.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-libs/glib:2
	dev-util/gtk-doc"

S="${S}${UVER}"

src_prepare() {
	ubuntu-versionator_src_prepare
	eautoreconf
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
