# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=+15.10.20150824.1
UREV=0ubuntu2

inherit cmake ubuntu-versionator

DESCRIPTION="Select objects in an object tree using XPath queries"
HOMEPAGE="https://launchpad.net/xpathselect"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="
	>=sys-devel/gcc-5.2
	>=sys-libs/glibc-2.14
"
DEPEND="
	dev-libs/boost:=

	test? ( dev-cpp/gtest )
"

S="${S}${UVER}"

src_prepare() {
	use test || sed -i '/add_subdirectory(test)/d' CMakeLists.txt || die

	ubuntu-versionator_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-Wno-dev
	)
	cmake_src_configure

	use test && echo 'subdirs("test")' > "${BUILD_DIR}"/CTestTestfile.cmake
}
