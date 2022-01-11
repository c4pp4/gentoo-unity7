# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
UBUNTU_EAUTORECONF="yes"

UVER=""
UREV="5ubuntu1"

inherit ubuntu-versionator

DESCRIPTION="X.Org dummy testing environment for Google Test"
HOMEPAGE="https://launchpad.net/xorg-gtest"
SRC_URI="${UURL}.orig.tar.bz2
	${UURL}-${UREV}.debian.tar.xz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc"
RESTRICT="${RESTRICT} test"

DEPEND="dev-util/valgrind
	x11-base/xorg-server
	x11-drivers/xf86-video-dummy
	x11-libs/libX11
	x11-libs/libXi
	doc? ( app-doc/doxygen )"

src_configure() {
	econf --with-doxygen=$(usex doc yes no)
}

src_install() {
	default

	# Remove files that collide with dev-cpp/gtest #
	rm "${ED}"usr/include/gtest/gtest-spi.h
	rm "${ED}"usr/include/gtest/gtest.h
}
