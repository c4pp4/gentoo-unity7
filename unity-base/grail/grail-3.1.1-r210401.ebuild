# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
UBUNTU_EAUTORECONF="yes"

UVER=""
UREV="3"

inherit ubuntu-versionator

DESCRIPTION="An implementation of the GRAIL (Gesture Recognition And Instantiation Library) interface"
HOMEPAGE="https://launchpad.net/grail"
SRC_URI="${UURL}.orig.tar.bz2"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"

DEPEND="
	>=sys-devel/gcc-4.6
	sys-libs/mtdev
	unity-base/evemu
	unity-base/frame
	x11-libs/libXi
	test? (
		dev-cpp/gtest
	)
"

src_configure() {
	econf \
		--enable-static=no \
		--enable-integration-tests=no \
		$(use_with test gtest-source-path)
}

src_install() {
	default

	find "${ED}" -name '*.la' -delete || die
}
