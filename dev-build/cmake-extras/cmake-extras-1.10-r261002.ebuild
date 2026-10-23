# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=1

inherit cmake ubuntu-versionator

DESCRIPTION="Extra CMake utility modules"
HOMEPAGE="https://launchpad.net/cmake-extras"
SRC_URI="${UURL}.orig.tar.bz2
	${UURL}-${UREV}.debian.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="examples"
RESTRICT="binchecks strip test"

RDEPEND="
	dev-build/cmake
	dev-lang/python-exec
	virtual/pkgconfig
"

src_install() {
	cmake_src_install

	# Support Gentoo Qt binaries path #
	sed -i \
		-e "s:/usr/lib/qt:/usr/$(get_libdir)/qt:" \
		"${ED}"/usr/share/cmake/QmlPlugins/QmlPluginsConfig.cmake || die
	grep -Fq "/usr/$(get_libdir)/qt" "${ED}"/usr/share/cmake/QmlPlugins/QmlPluginsConfig.cmake || die

	use examples && dodoc -r examples
}
