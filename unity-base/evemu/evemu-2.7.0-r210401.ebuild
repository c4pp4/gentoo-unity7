# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{8..11} )
UBUNTU_EAUTORECONF="yes"

UVER=
UREV=3

inherit python-single-r1 ubuntu-versionator

DESCRIPTION="Linux Input Event Device Emulation Library"
HOMEPAGE="https://www.freedesktop.org/wiki/Evemu"
SRC_URI="${UURL}.orig.tar.xz
	${UURL}-${UREV}.debian.tar.xz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RESTRICT="!test? ( test )"

COMMON_DEPEND=">=dev-libs/libevdev-1.2.99.902"
RDEPEND="${COMMON_DEPEND}
	>=sys-libs/glibc-2.8
"
DEPEND="${COMMON_DEPEND}
	app-text/asciidoc[${PYTHON_SINGLE_USEDEP}]
	app-text/xmlto

	${PYTHON_DEPS}
"
BDEPEND="virtual/pkgconfig"

S="${S}${UVER}"

MAKEOPTS="${MAKEOPTS} -j1"

src_configure() {
	local myeconfargs=(
		--enable-static=no
		$(use_enable test tests)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
