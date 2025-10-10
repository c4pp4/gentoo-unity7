# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=2

inherit cmake ubuntu-versionator

DESCRIPTION="Parse and query the geonames database dump"
HOMEPAGE="https://launchpad.net/geonames"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.debian.tar.xz"

LICENSE="CC-BY-3.0 GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="demo doc test"
RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/glib-2.39.91:2
	>=sys-libs/glibc-2.4
"
DEPEND="${RDEPEND}"

BDEPEND="
	dev-util/intltool
	virtual/pkgconfig

	doc? (
		>=dev-util/gtk-doc-1.21
		app-misc/rdfind
		app-misc/symlinks
	)
"

src_configure() {
	local mycmakeargs=(
		-DWANT_DEMO=$(usex demo ON OFF)
		-DWANT_DOC=$(usex doc ON OFF)
		-DWANT_TESTS=$(usex test ON OFF)
	)
	cmake_src_configure
}

src_test() {
	LC_ALL=en_US.UTF-8 cmake_src_test
}

src_install() {
	cmake_src_install

	if use doc; then
		# Taken from 'rules' #
		pushd "${ED}"/usr/share/gtk-doc/html/"${PN}" >/dev/null || die
			find -name *.md5 -delete
			rdfind -makesymlinks true .
			symlinks -rc .
			rm results.txt
		popd >/dev/null || die
	fi
}
