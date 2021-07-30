# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

URELEASE="hirsute"
inherit autotools ubuntu-versionator

DESCRIPTION="X.Org dummy testing environment for Google Test"
HOMEPAGE="https://launchpad.net/xorg-gtest"
SRC_URI="${UURL}/${MY_P}.orig.tar.bz2
	${UURL}/${MY_P}-${UVER}.debian.tar.xz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc"
RESTRICT="mirror test"

DEPEND="dev-util/valgrind
	x11-base/xorg-server
	x11-drivers/xf86-video-dummy
	x11-libs/libX11
	x11-libs/libXi
	doc? ( app-doc/doxygen )"

src_prepare() {
	ubuntu-versionator_src_prepare
	eautoreconf
}

src_compile() {
	emake || die
	use doc && emake doc
}

src_install() {
	emake DESTDIR="${D}" install

	# Remove files that collide with dev-cpp/gtest #
	rm "${ED}"usr/include/gtest/gtest-spi.h
	rm "${ED}"usr/include/gtest/gtest.h
}
