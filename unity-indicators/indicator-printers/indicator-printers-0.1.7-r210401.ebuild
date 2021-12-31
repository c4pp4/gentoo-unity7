# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
GNOME2_EAUTORECONF="yes"
GNOME2_LA_PUNT="yes"

UVER="+17.10.20171101"
UREV="0ubuntu3"

inherit gnome2 ubuntu-versionator

DESCRIPTION="Indicator showing active print jobs used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/indicator-printers"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="app-admin/system-config-printer
	dev-libs/glib:2
	dev-libs/libappindicator
	dev-libs/libdbusmenu[gtk3]
	dev-libs/libindicator:3
	net-print/cups[dbus]
	x11-libs/cairo
	x11-libs/gdk-pixbuf
	x11-libs/gtk+:3
	x11-libs/pango"

S="${S}${UVER}"

src_prepare() {
	sed -i 's/SESSION=ubuntu/SESSION=unity/' data/indicator-printers.conf.in
	ubuntu-versionator_src_prepare
}

src_install() {
	gnome2_src_install
	cd debian/local
		for file in $(find . -name printer-symbolic.svg); do
			insinto /usr/share/icons/$(dirname "${file}")
			doins "${file}"
		done
}

pkg_postinst() {
	ubuntu-versionator_pkg_postinst
	elog "Please note the printer jobs indicator requires the cupsd daemon to be"
	elog " running so that it can grab printer job status from cups dbus notifier"
}
