# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
UBUNTU_EAUTORECONF="yes"

UVER=
UREV=3

inherit ubuntu-versionator

DESCRIPTION="An implementation of the GRAIL (Gesture Recognition And Instantiation Library) interface"
HOMEPAGE="https://launchpad.net/grail"
SRC_URI="${UURL}.orig.tar.bz2"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"
RESTRICT="${RESTRICT} !test? ( test )"

COMMON_DEPEND="
	>=unity-base/frame-2.5.0
	>=x11-libs/libX11-1.4.99
	>=x11-libs/libXext-1.3
	>=x11-libs/libXi-1.5.99.2
"
RDEPEND="${COMMON_DEPEND}
	>=sys-devel/gcc-5.2
	>=sys-libs/glibc-2.15
"
DEPEND="${COMMON_DEPEND}
	>=x11-base/xorg-proto-2.1.99.5

	test? ( dev-cpp/gtest )
"
BDEPEND="virtual/pkgconfig"

src_configure() {
	local myeconfargs=(
		--enable-static=no
		--enable-integration-tests=no
		$(use_with test gtest-source-path)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
