# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=3

inherit cmake ubuntu-versionator

DESCRIPTION="Extra CMake utility modules"
HOMEPAGE="https://launchpad.net/cmake-extras"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.debian.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="examples test"
RESTRICT="binchecks strip !test? ( test )"

RDEPEND="
	dev-lang/python-exec
	virtual/pkgconfig

	test? ( >=dev-cpp/gtest-1.10 )
"

src_install() {
	cmake_src_install
	use examples && ( dodoc -r examples || die )
}
