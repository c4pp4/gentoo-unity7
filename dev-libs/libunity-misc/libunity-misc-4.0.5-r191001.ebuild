# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

UVER="+14.04.20140115"
UREV="0ubuntu3"

inherit autotools ubuntu-versionator

DESCRIPTION="Miscellaneous modules for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/libunity-misc"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0/4.1.0"
KEYWORDS="~amd64"
IUSE="doc"

DEPEND="x11-libs/gtk+:3
	x11-libs/libXfixes
	dev-util/gtk-doc-am
	dev-util/gtk-doc"

S="${S}${UVER}"

src_prepare() {
	ubuntu-versionator_src_prepare

	# Make docs optional #
	use doc || sed -i \
		-e 's:unity-misc doc:unity-misc:' \
		Makefile.am

	eautoreconf
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
