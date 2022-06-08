# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
UBUNTU_EAUTORECONF="yes"

UVER=+17.04.20170220
UREV=0ubuntu4

inherit ubuntu-versionator

DESCRIPTION="Parse and query the geonames database dump"
HOMEPAGE="https://launchpad.net/geonames"
SRC_URI="${UURL}-${UREV}.tar.xz"

LICENSE="CC-BY-3.0 GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc"

RDEPEND="
	>=dev-libs/glib-2.39.91:2
	>=sys-libs/glibc-2.4
"
DEPEND="${RDEPEND}
	doc? ( >=dev-util/gtk-doc-1.21 )
"
BDEPEND="
	dev-util/intltool
	virtual/pkgconfig
"

S="${S}${UVER}"

src_configure() {
	econf $(use_enable doc gtk-doc)
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
