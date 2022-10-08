# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

COMMIT="41a9b524efc767a8990532667a92748235ed6917"
MY_PN="indicator-netspeed-unity"

inherit gnome2

DESCRIPTION="Network speed indicator for Unity"
HOMEPAGE="https://github.com/GGleb/indicator-netspeed-unity"
SRC_URI="https://github.com/GGleb/${MY_PN}/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="mirror test"

COMMON_DEPEND="
	>=dev-libs/libappindicator-0.2.92:3
	>=gnome-base/libgtop-2.22.3:2=
	net-analyzer/nethogs
	>=x11-libs/gtk+-3.0.0:3
"
RDEPEND="${COMMON_DEPEND}
	>=dev-libs/glib-2.26.0:2
	gnome-base/dconf
	>=sys-libs/glibc-2.4
	>=x11-libs/pango-1.14.0
"
DEPEND="${COMMON_DEPEND}"

S="${WORKDIR}/${MY_PN}-${COMMIT}"

src_prepare() {
	# Don't strip #
	sed -i "s/-s ${MY_PN}/${MY_PN}/" Makefile || die

	gnome2_src_prepare
}

src_configure() { :; }
