# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

UVER="+15.10.20150824.1"
UREV="0ubuntu2"

inherit cmake-utils ubuntu-versionator

DESCRIPTION="Select objects in an object tree using XPath queries"
HOMEPAGE="https://launchpad.net/xpathselect"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"

DEPEND="test? ( dev-cpp/gtest )
	dev-libs/boost"

S="${S}${UVER}"
DOCS=( COPYING )

src_prepare() {
	use test || sed -i '/add_subdirectory(test)/d' CMakeLists.txt
	ubuntu-versionator_src_prepare
}
