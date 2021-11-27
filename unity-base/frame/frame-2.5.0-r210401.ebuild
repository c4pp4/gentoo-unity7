# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

UVER="daily13.06.05+16.10.20160809"
UREV="0ubuntu3"

inherit autotools ubuntu-versionator

DESCRIPTION="uTouch Frame Library"
HOMEPAGE="https://launchpad.net/frame"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"

DEPEND="app-text/asciidoc
	>=sys-devel/gcc-4.6
	sys-libs/mtdev
	unity-base/evemu
	x11-base/xorg-server[dmx]
	x11-libs/libXi
	test? ( sys-apps/xorg-gtest )"

S="${WORKDIR}"

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
