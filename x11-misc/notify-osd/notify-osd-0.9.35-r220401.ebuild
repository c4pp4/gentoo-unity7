# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
GNOME2_EAUTORECONF="yes"

UVER=+20.04.20191129
UREV=0ubuntu2

inherit gnome2 savedconfig ubuntu-versionator

DESCRIPTION="Canonical's on-screen-display notification agent"
HOMEPAGE="https://launchpad.net/notify-osd"

LICENSE="LGPL-2+ GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="minimal"
RESTRICT="test"

COMMON_DEPEND="
	>=dev-libs/dbus-glib-0.88
	>=dev-libs/glib-2.37.3:2
	>=sys-apps/dbus-1.9.14
	>=x11-libs/gtk+-3.9.10:3
	>=x11-libs/libwnck-3.4.0:3
"
RDEPEND="${COMMON_DEPEND}
	>=dev-libs/atk-1.12.4
	gnome-base/dconf
	gnome-base/gsettings-desktop-schemas
	>=sys-libs/glibc-2.34
	>=x11-libs/cairo-1.14.0
	>=x11-libs/gdk-pixbuf-2.22.0:2
	x11-libs/libX11
	>=x11-libs/pango-1.20.0
	>=x11-libs/pixman-0.30.0

	!minimal? ( x11-themes/notify-osd-icons )
"
DEPEND="${COMMON_DEPEND}
	gnome-base/gnome-common
	>=x11-libs/libnotify-0.6.1
"
BDEPEND="dev-util/intltool"

S="${WORKDIR}"

src_prepare() {
	# Fix icons dir and don't include README #
	sed -i \
		-e "s/pkgdatadir/datadir/" \
		-e "/README/d" \
		data/icons/scalable/Makefile.am || die

	# b.g.o #428134 #
	restore_config src/{bubble,defaults,dnd}.c

	ubuntu-versionator_src_prepare
}

src_configure() {
	local myeconfargs=(
		--libexecdir=/usr/$(get_libdir)/"${PN}"
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default

	save_config src/{bubble,defaults,dnd}.c

	# kde-plasma/plasma-workspace provides a similar DBUS service that conflicts #
	#  by advertising the same 'org.freedesktop.Notifications' name on DBUS #
	#  This can cause dbus to fail both services in turn causing multimedia keys function to fail #
	#  Other side-effect symptoms include nm-applet displaying incorrect network connectivity state and mouse cursor slow to appear on login #
	if [[ -n $(grep org.freedesktop.Notifications$ /usr/share/dbus-1/services/* | grep -v org.freedesktop.Notifications.service) ]]; then
		einfo
		einfo "Conflicting notification service(s) have been found in /usr/share/dbus-1/services/"
		einfo "Installing workaround as /etc/xdg/autostart/notify-osd.desktop"
		einfo "Consider removing duplicate entries and re-emerging x11-misc/notify-osd"
		einfo " to have notifications work at Display Manager login"
		einfo "Review conflicting notification service(s) below:"
		einfo
		einfo "$(grep org.freedesktop.Notifications$ /usr/share/dbus-1/services/* | grep -v org.freedesktop.Notifications.service)"
		einfo
		rm -f "${ED}"/usr/share/dbus-1/services/org.freedesktop.Notifications.service
		insinto /etc/xdg/autostart
		doins "${FILESDIR}"/notify-osd.desktop
	fi
}

pkg_postinst() {
	savedconfig_pkg_postinst
	ubuntu-versionator_pkg_postinst
}
