# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
UBUNTU_EAUTORECONF="yes"

UVER=+19.04.20190308.1
UREV=0ubuntu6

inherit ubuntu-versionator

DESCRIPTION="Application indicators used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/indicator-application"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"
S="${WORKDIR}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="test"

COMMON_DEPEND="
	>=dev-libs/dbus-glib-0.88
	>=dev-libs/glib-2.37.3:2
	>=dev-libs/libappindicator-0.2.92:3
	>=dev-libs/libdbusmenu-0.5.90:=[gtk3]
	>=dev-libs/libindicator-0.4.90:3
	>=x11-libs/gtk+-3.0.0:3
	>=x11-libs/pango-1.14.0
"
RDEPEND="${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND}
	dev-libs/json-glib
	sys-apps/systemd
"
BDEPEND="
	dev-util/intltool
	virtual/pkgconfig
"

src_prepare() {
	# Fix desktop file installation location #
	sed -i \
		-e 's:$(pkgdatadir)/upstart/xdg/autostart:$(datadir)/upstart/xdg/autostart:g' \
		data/upstart/Makefile.am || die

	ubuntu-versionator_src_prepare
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
