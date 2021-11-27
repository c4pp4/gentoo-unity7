# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{8..10} )

UVER=""
UREV="3"

inherit autotools python-single-r1 ubuntu-versionator

DESCRIPTION="Event Emulation for the uTouch Stack"
HOMEPAGE="https://launchpad.net/evemu"
SRC_URI="${UURL}.orig.tar.xz
	${UURL}-${UREV}.debian.tar.xz"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="app-text/asciidoc
	app-text/xmlto
	dev-libs/libevdev
	${PYTHON_DEPS}"

S="${S}${UVER}"
MAKEOPTS="${MAKEOPTS} -j1"

src_prepare() {
	ubuntu-versionator_src_prepare
	eautoreconf
}

src_configure() {
	econf --enable-static=no \
		$(use_enable test tests)
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
