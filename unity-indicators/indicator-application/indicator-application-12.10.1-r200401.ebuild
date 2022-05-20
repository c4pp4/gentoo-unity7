# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
UBUNTU_EAUTORECONF="yes"

UVER=+19.04.20190308.1
UREV=0ubuntu3

inherit ubuntu-versionator

DESCRIPTION="Application indicators used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/indicator-application"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="${RESTRICT} test"

COMMON_DEPEND="
	>=dev-libs/dbus-glib-0.88
	>=dev-libs/glib-2.37.3:2
	>=dev-libs/libappindicator-0.2.92:3
	>=dev-libs/libdbusmenu-0.5.90:=[gtk3]
	>=dev-libs/libindicator-0.4.90:3
	>=x11-libs/gtk+-3.0.0:3
"
RDEPEND="${COMMON_DEPEND}
	>=sys-libs/glibc-2.4
	>=x11-libs/pango-1.14.0
"
DEPEND="${COMMON_DEPEND}
	dev-libs/json-glib
	gnome-base/gnome-common
	sys-apps/systemd
"
BDEPEND="dev-util/intltool"

S="${WORKDIR}"

src_prepare() {
	# Fix desktop file installation location #
	sed -i \
		-e 's:$(pkgdatadir)/upstart/xdg/autostart:$(datadir)/upstart/xdg/autostart:g' \
		data/upstart/Makefile.am

	ubuntu-versionator_src_prepare
}

src_install() {
	default
	find "${ED}" \( -name "*.a" -o -name "*.la" \) -delete || die
}
