# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
GNOME2_EAUTORECONF="yes"

UVER=+21.10.20210715
UREV=0ubuntu1

inherit flag-o-matic gnome2 ubuntu-versionator

DESCRIPTION="Unity Settings Daemon"
HOMEPAGE="https://launchpad.net/unity-settings-daemon"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+colord debug +fcitx +i18n +input_devices_wacom nls +short-touchpad-timeout smartcard +udev"
REQUIRED_USE="
	input_devices_wacom? ( udev )
	smartcard? ( udev )
"
RESTRICT="test"

COMMON_DEPEND="
	>=dev-libs/dbus-glib-0.74
	>=dev-libs/glib-2.39.4:2
	>=gnome-base/gnome-desktop-3.17.92:3=
	>=gnome-base/gsettings-desktop-schemas-3.15.4
	>=media-libs/alsa-lib-1.0.16
	>=media-libs/fontconfig-2.12.6:1.0
	>=media-libs/lcms-2.2:2
	>=media-libs/libcanberra-0.25[gtk3]
	>=media-sound/pulseaudio-2.0[glib]
	>=net-misc/networkmanager-1.0.0
	>=sys-apps/accountsservice-0.6.40
	>=sys-power/upower-0.99.1:=
	>=unity-base/gsettings-ubuntu-touch-schemas-0.0.7
	>=x11-libs/gdk-pixbuf-2.23.0:2
	>=x11-libs/gtk+-3.9.10:3
	>=x11-libs/libnotify-0.7.3:=
	x11-libs/libX11
	x11-libs/libXext
	>=x11-libs/libXi-1.2.99.4
	>=x11-libs/libxkbfile-1.1.0
	x11-libs/libXtst

	colord? ( >=x11-misc/colord-1.4.3:= )
	fcitx? (
		>=app-i18n/fcitx-4.2.9.5
		app-i18n/fcitx-configtool
	)
	i18n? ( >=app-i18n/ibus-1.5.1 )
	input_devices_wacom? (
		>=gnome-base/librsvg-2.36.2
		>=dev-libs/libwacom-1.1
	)
	udev? (
		>=dev-libs/libgudev-146:=
		virtual/libudev:=
	)
"
RDEPEND="${COMMON_DEPEND}
	gnome-base/dconf
	media-libs/libglvnd
	>=sys-libs/glibc-2.33
	unity-base/session-migration
	>=x11-libs/cairo-1.14.0
	>=x11-libs/libXfixes-4.0.1
	>=x11-libs/libXrandr-1.2.99.3
	>=x11-libs/pango-1.22.0
	x11-wm/metacity
"
DEPEND="${COMMON_DEPEND}
	>=dev-libs/libappindicator-0.4.90:3
	dev-util/gperf
	>=gnome-base/libgnomekbd-3.5.1
	sys-apps/hwdata
	>=sys-apps/systemd-183
	sys-auth/polkit
	x11-libs/libxklavier
	x11-libs/libXt
	x11-misc/xkeyboard-config

	input_devices_wacom? ( x11-drivers/xf86-input-wacom )
	smartcard? ( dev-libs/nss )
"
BDEPEND=" >=dev-util/intltool-0.37.1"

S="${WORKDIR}"

PATCHES=(
	"${FILESDIR}"/01_"${PN}"-optional-color-wacom.patch # Make colord and wacom optional; requires eautoreconf
	"${FILESDIR}"/02_"${PN}"-2021-optional-pnp-ids.patch # pnp.ids is not provided by >=gnome-base/gnome-desktop-3.21.4; use udev's hwdb to query PNP IDs instead
	"${FILESDIR}"/remove-nautilus-support.patch
	"${FILESDIR}"/shortcut-alt-app.patch
)

src_prepare() {
	# https://bugzilla.gnome.org/show_bug.cgi?id=621836
	# Apparently this change severely affects touchpad usability for some
	# people, so revert it if USE=short-touchpad-timeout.
	# Revisit if/when upstream adds a setting for customizing the timeout.
	use short-touchpad-timeout \
		&& eapply "${FILESDIR}/${PN}-3.7.90-short-touchpad-timeout.patch"

	# Ensure libunity-settings-daemon.so.1 gets linked to libudev.so #
	sed -i 's:-lm :-lm -ludev :g' gnome-settings-daemon/Makefile.am || die

	# Disable all language files as they can be incomplete #
	#  due to being provided by Ubuntu's language-pack packages #
	> po/LINGUAS

	ubuntu-versionator_src_prepare

	# Correct path to unity-settings-daemon executable in upstart and systemd files #
	sed -i \
		-e 's:/usr/lib/unity-settings-daemon:/usr/libexec:g' \
		debian/unity-settings-daemon.user-session.{desktop,upstart} \
		debian/user/unity-settings-daemon.service || die

	#  'After=graphical-session-pre.target' must be explicitly set in the unit files that require it #
	#  Relying on the upstart job /usr/share/upstart/systemd-session/upstart/systemd-graphical-session.conf #
	#       to create "$XDG_RUNTIME_DIR/systemd/user/${unit}.d/graphical-session-pre.conf" drop-in units #
	#       results in weird race problems on desktop logout where the reliant desktop services #
	#       stop in a different jumbled order each time #
	sed -i \
		-e '/PartOf=/i After=graphical-session-pre.target' \
		debian/user/unity-settings-daemon.service || die
}

src_configure() {
	append-ldflags -Wl,--warn-unresolved-symbols
	use input_devices_wacom \
		&& append-cflags -Wno-deprecated-declarations -I/usr/include/librsvg-2.0

	local mygnome2args=(
		--disable-static
		--enable-man
		--disable-packagekit
		$(use_enable colord color)
		$(use_enable debug)
		$(use_enable debug more-warnings)
		$(use_enable fcitx)
		$(use_enable i18n ibus)
		$(use_enable nls)
		$(use_enable smartcard smartcard-support)
		$(use_enable udev gudev)
		$(use_enable udev)
		$(use_enable input_devices_wacom wacom)
	)
	gnome2_src_configure "${mygnome2args[@]}"
}

src_install() {
	gnome2_src_install

	# Install upstart files #
	insinto /usr/share/upstart/xdg/autostart
	newins debian/unity-settings-daemon.user-session.desktop unity-settings-daemon.desktop
	insinto /usr/share/upstart/sessions/
	newins debian/unity-settings-daemon.user-session.upstart unity-settings-daemon.conf

	# Install systemd units #
	insinto /usr/lib/systemd/user
	doins debian/user/unity-settings-daemon.service
	insinto /usr/share/upstart/systemd-session/upstart
	doins debian/user/unity-settings-daemon.override
}
