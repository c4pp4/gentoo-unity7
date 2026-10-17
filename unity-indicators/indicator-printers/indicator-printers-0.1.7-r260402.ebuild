# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
GNOME2_EAUTORECONF="yes"
GNOME2_LA_PUNT="yes"

UVER=+17.10.20171101
UREV=0ubuntu8

inherit gnome2 systemd ubuntu-versionator

DESCRIPTION="Indicator showing active print jobs used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/indicator-printers"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"
S="${S}${UVER}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="systemd"

COMMON_DEPEND="
	>=dev-libs/glib-2.43.2:2
	>=dev-libs/libdbusmenu-0.5.90:=[gtk3]
	>=dev-libs/libindicator-0.4.90:3
	>=net-print/cups-1.6.0[dbus]
	>=x11-libs/cairo-1.2.4
	>=x11-libs/gdk-pixbuf-2.22.0:2
	>=x11-libs/gtk+-3.0.0:3
	>=x11-libs/pango-1.18.0
"
RDEPEND="${COMMON_DEPEND}
	app-admin/system-config-printer
	net-print/cups-meta
"
DEPEND="${COMMON_DEPEND}"
BDEPEND="
	dev-util/intltool
	sys-devel/gettext
	virtual/pkgconfig
"

src_prepare() {
	sed -i 's/SESSION=ubuntu/SESSION=unity/' data/indicator-printers.conf.in || die

	ubuntu-versionator_src_prepare

	# Install the systemd user unit even without sys-apps/systemd #
	sed -i \
		-e "s:^SYSTEMD_USERDIR=.*:SYSTEMD_USERDIR=$(systemd_get_userunitdir):" \
		configure || die
}

src_install() {
	gnome2_src_install

	insinto /usr/share/icons
	doins -r debian/local/ubuntu-mono-{dark,light}

	# Start indicator service via cinnamon-session without systemd #
	if ! use systemd; then
		insinto /etc/xdg/autostart
		doins "${FILESDIR}"/indicator-printers.desktop
	fi
}

pkg_postinst() {
	ubuntu-versionator_pkg_postinst

	elog "Please note the printer jobs indicator requires the cupsd daemon to be"
	elog "running so that it can grab printer job status from cups dbus notifier"
}
