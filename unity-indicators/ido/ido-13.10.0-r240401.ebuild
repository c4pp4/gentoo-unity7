# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
UBUNTU_EAUTORECONF="yes"

UVER=+22.10.20221007
UREV=0ubuntu3

inherit vala ubuntu-versionator

DESCRIPTION="Widgets and other objects used for indicators by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/ido"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="LGPL-2.1 LGPL-3"
SLOT="0/$(usub)"
KEYWORDS="~amd64"
RESTRICT="test"

COMMON_DEPEND="
	>=dev-libs/glib-2.41.1:2
	>=x11-libs/gtk+-3.8.2:3
"
RDEPEND="${COMMON_DEPEND}
	>=sys-libs/glibc-2.29
	virtual/pkgconfig
	>=x11-libs/cairo-1.2.4
	>=x11-libs/gdk-pixbuf-2.23.0:2
	>=x11-libs/pango-1.20.0
"
DEPEND="${COMMON_DEPEND}
	dev-libs/gobject-introspection
	gnome-base/gnome-common
	x11-libs/libX11
	x11-libs/libXi

	$(vala_depend)
"

S="${WORKDIR}"

src_prepare() {
	# CHECK_XORG_GTEST: command not found #
	sed -i "/CHECK_XORG_GTEST/d" configure.ac || die

	ubuntu-versionator_src_prepare
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
