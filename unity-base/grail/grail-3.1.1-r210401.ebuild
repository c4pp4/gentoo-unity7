# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

UVER=""
UREV="3"

inherit autotools ubuntu-versionator

DESCRIPTION="An implementation of the GRAIL (Gesture Recognition And Instantiation Library) interface"
HOMEPAGE="https://launchpad.net/grail"
SRC_URI="${UURL}.orig.tar.bz2"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"

DEPEND=">=sys-devel/gcc-4.6
	sys-libs/mtdev
	unity-base/evemu
	unity-base/frame
	x11-libs/libXi
	test? ( sys-apps/xorg-gtest )"

S="${S}${UVER}"

src_prepare() {
	ubuntu-versionator_src_prepare
	eautoreconf
}

src_configure() {
	econf --enable-static=no \
		$(use_enable test integration-tests)
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
