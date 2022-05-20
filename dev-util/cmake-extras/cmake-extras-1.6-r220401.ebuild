# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

UVER=
UREV=1

inherit cmake-utils ubuntu-versionator

DESCRIPTION="Extra CMake utility modules"
HOMEPAGE="https://launchpad.net/cmake-extras"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.debian.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="examples test"
RESTRICT="${RESTRICT} binchecks strip !test? ( test )"

RDEPEND="
	dev-lang/python-exec
	virtual/pkgconfig

	test? ( >=dev-cpp/gtest-1.10 )
"

src_install() {
	cmake-utils_src_install
	use examples && ( dodoc -r examples || die )
}
