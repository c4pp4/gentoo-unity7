# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
UBUNTU_EAUTORECONF="yes"

UVER=""
UREV="1ubuntu3"

inherit ubuntu-versionator

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
	sed -i \
		-e "s:doc/libzeitgeist:doc/${PF}:" \
		Makefile.am || die

	ubuntu-versionator_src_prepare
}
