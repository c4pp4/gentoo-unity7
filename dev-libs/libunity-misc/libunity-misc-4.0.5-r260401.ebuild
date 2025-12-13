# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
UBUNTU_EAUTORECONF="yes"

UVER=+14.04.20140115
UREV=0ubuntu6

inherit ubuntu-versionator

DESCRIPTION="Miscellaneous modules for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/libunity-misc"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-2 LGPL-2 LGPL-3"
SLOT="0/$(usub)"
KEYWORDS="~amd64"
IUSE="doc"
RESTRICT="test"

COMMON_DEPEND="
	>=dev-libs/glib-2.37.3:2
	>=x11-libs/gtk+-3.0:3[X]
"
RDEPEND="${COMMON_DEPEND}
	>=sys-libs/glibc-2.14
	>=x11-libs/cairo-1.2.4

	doc? ( dev-util/devhelp )
"
DEPEND="${COMMON_DEPEND}
	gnome-base/gnome-common

	doc? ( dev-util/gtk-doc )
"

S="${S}${UVER}"

src_configure() {
	local myeconfargs=(
		$(use_enable doc gtk-doc)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
