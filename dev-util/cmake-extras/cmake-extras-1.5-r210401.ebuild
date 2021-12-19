# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

UVER=""
UREV="7"

inherit cmake-utils ubuntu-versionator

DESCRIPTION="Extra CMake utility modules"
HOMEPAGE="http://launchpad.net/cmake-extras"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.debian.tar.xz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="examples"

src_install() {
	cmake-utils_src_install

	if use examples; then
		insinto /usr/share/doc/${PF}/
		doins -r examples
	fi
}