# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
UBUNTU_EAUTORECONF="yes"

UVER=
UREV=0ubuntu4

inherit gnome2 ubuntu-versionator

DESCRIPTION="View recent notifications"
HOMEPAGE="https://launchpad.net/recent-notifications"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="test"

COMMON_DEPEND="
	>=dev-libs/glib-2.39.4:2
	>=dev-libs/libindicator-0.4.90:3
	>=x11-libs/gtk+-3.21.4:3
"
RDEPEND="${COMMON_DEPEND}
	gnome-base/dconf
	>=sys-libs/glibc-2.4
"
DEPEND="${COMMON_DEPEND}
	>=x11-libs/gdk-pixbuf-2.22:2
"
BDEPEND="
	dev-util/intltool
	virtual/pkgconfig
"

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
