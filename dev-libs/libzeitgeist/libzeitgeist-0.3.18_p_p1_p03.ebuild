# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

URELEASE="impish"
inherit autotools ubuntu-versionator

DESCRIPTION="Client library to interact with zeitgeist"
HOMEPAGE="https://launchpad.net/libzeitgeist/"
SRC_URI="${UURL}/${MY_P}.orig.tar.gz
	${UURL}/${MY_P}-${UVER}.debian.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="static-libs"
RESTRICT="mirror"

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

#	# FIXME: This is the unique test failing
#	sed \
#		-e '/TEST_PROGS      += test-log/d' \
#		-i tests/Makefile.am || die
#
#	sed \
#		-e 's/AM_CONFIG_HEADER/AC_CONFIG_HEADERS/g' \
#		-e 's:AM_PROG_CC_STDC:AC_PROG_CC:g' \
#		-i configure.ac || die

	eautoreconf
}
