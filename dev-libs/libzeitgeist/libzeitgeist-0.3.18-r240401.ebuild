# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
UBUNTU_EAUTORECONF="yes"

UVER=
UREV=1ubuntu6

inherit ubuntu-versionator

DESCRIPTION="Client library to interact with zeitgeist"
HOMEPAGE="https://launchpad.net/libzeitgeist/"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.debian.tar.xz"

LICENSE="GPL-3 LGPL-2.1"
SLOT="0"
KEYWORDS="amd64"
IUSE="doc"

COMMON_DEPEND="
	>=dev-libs/glib-2.37.3:2
"
RDEPEND="${COMMON_DEPEND}
	gnome-extra/zeitgeist
	>=sys-libs/glibc-2.4

	doc? ( dev-util/devhelp )
"
DEPEND="${COMMON_DEPEND}
	>=sys-apps/dbus-1.0

	doc? ( dev-util/gtk-doc )
"

src_prepare() {
	# Fix doc dir #
	sed -i "s:/doc/libzeitgeist:/doc/${PF}:" Makefile.am || die

	# Make gtk-doc-html really optional #
	use doc || sed -i "/doc /d" Makefile.am || die

	ubuntu-versionator_src_prepare
}

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
