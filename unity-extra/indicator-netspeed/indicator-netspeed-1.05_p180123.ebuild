# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

COMMIT="41a9b524efc767a8990532667a92748235ed6917"
MY_PN="indicator-netspeed-unity"

inherit gnome2

DESCRIPTION="Network speed indicator for Unity"
HOMEPAGE="https://github.com/GGleb/indicator-netspeed-unity"
SRC_URI="https://github.com/GGleb/${MY_PN}/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${MY_PN}-${COMMIT}"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="mirror test"

COMMON_DEPEND="
	>=dev-libs/glib-2.26.0:2
	>=dev-libs/libappindicator-0.2.92:3
	>=gnome-base/libgtop-2.22.3:2=
	>=x11-libs/gtk+-3.0.0:3
	>=x11-libs/pango-1.14.0
"
RDEPEND="${COMMON_DEPEND}
	gnome-base/dconf
	net-analyzer/nethogs
"
DEPEND="${COMMON_DEPEND}"
BDEPEND="virtual/pkgconfig"

src_prepare() {
	# Don't strip #
	sed -i "s/-s ${MY_PN}/${MY_PN}/" Makefile || die

	gnome2_src_prepare
}

src_configure() { :; }
