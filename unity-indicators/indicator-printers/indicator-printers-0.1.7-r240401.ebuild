# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
GNOME2_EAUTORECONF="yes"
GNOME2_LA_PUNT="yes"

UVER=+17.10.20171101
UREV=0ubuntu7

inherit gnome2 ubuntu-versionator

DESCRIPTION="Indicator showing active print jobs used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/indicator-printers"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

COMMON_DEPEND="
	>=dev-libs/glib-2.43.2:2
	>=dev-libs/libdbusmenu-0.5.90:=[gtk3]
	>=dev-libs/libindicator-0.4.90:3
	>=net-print/cups-1.6.0[dbus]
	>=x11-libs/gtk+-3.0.0:3
"
RDEPEND="${COMMON_DEPEND}
	app-admin/system-config-printer
	>=sys-libs/glibc-2.4
	>=x11-libs/cairo-1.2.4
	>=x11-libs/gdk-pixbuf-2.22.0:2
	>=x11-libs/pango-1.18.0
"
DEPEND="${COMMON_DEPEND}
	gnome-base/gnome-common
	sys-apps/systemd
"

S="${S}${UVER}"

src_prepare() {
	sed -i 's/SESSION=ubuntu/SESSION=unity/' data/indicator-printers.conf.in

	ubuntu-versionator_src_prepare
}

src_install() {
	gnome2_src_install

	insinto /usr/share/icons
	doins -r debian/local/ubuntu-mono-{dark,light}
}

pkg_postinst() {
	ubuntu-versionator_pkg_postinst

	elog "Please note the printer jobs indicator requires the cupsd daemon to be"
	elog "running so that it can grab printer job status from cups dbus notifier"
}
