# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=+15.10.20150824.1
UREV=0ubuntu2

inherit cmake ubuntu-versionator

DESCRIPTION="Select objects in an object tree using XPath queries"
HOMEPAGE="https://launchpad.net/xpathselect"
S="${S}${UVER}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="test"
RESTRICT="!test? ( test )"

DEPEND="
	dev-libs/boost

	test? ( dev-cpp/gtest )
"

src_prepare() {
	# Fix build with CMake 4 #
	sed -i "/cmake_minimum_required/{s/2\.6/3.10/}" CMakeLists.txt || die

	# Fix libdir #
	sed -i "s:/lib:/$(get_libdir):" lib/xpathselect.pc.in || die

	if use test; then
		# Use system gtest instead of building it from /usr/src/gtest #
		sed -i \
			-e "/add_dependencies (test-runner/d" \
			-e "/add_subdirectory(/,/)/d" \
			-e "/add_custom_target (test /d" \
			-e "s/-std=c++11/-std=c++17/" \
			test/CMakeLists.txt || die
	else
		# Make test optional #
		cmake_comment_add_subdirectory test
	fi

	ubuntu-versionator_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-Wno-dev
	)
	cmake_src_configure

	use test && echo 'subdirs("test")' > "${BUILD_DIR}"/CTestTestfile.cmake
}
