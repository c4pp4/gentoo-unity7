# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
GNOME2_EAUTORECONF="yes"

UVER="+21.10.20210715"
UREV="0ubuntu1"

inherit flag-o-matic gnome2 virtualx ubuntu-versionator

DESCRIPTION="Unity Settings Daemon"
HOMEPAGE="https://launchpad.net/unity-settings-daemon"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-2"
SLOT="0"
IUSE="+colord debug +fcitx +i18n +input_devices_wacom nls +short-touchpad-timeout smartcard +udev"
KEYWORDS="~amd64"
REQUIRED_USE="input_devices_wacom? ( udev )
		smartcard? ( udev )"

# require colord-0.1.27 dependency for connection type support
DEPEND="dev-libs/glib:2
	dev-libs/libappindicator:=
	x11-libs/gtk+:3
	>=gnome-base/gnome-desktop-3.36:3=
	gnome-base/gsettings-desktop-schemas
	gnome-base/librsvg
	media-libs/fontconfig
	media-libs/lcms:2
	media-libs/libcanberra[gtk3]
	media-sound/pulseaudio
	sys-apps/accountsservice
	sys-apps/hwdata
	>=sys-apps/systemd-232
	>=sys-power/upower-0.99:=
	unity-base/gsettings-ubuntu-touch-schemas
	unity-base/session-migration
	x11-apps/xinput
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/libnotify:=
	x11-libs/libX11
	x11-libs/libxkbfile
	x11-libs/libXi
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXtst

	sys-auth/polkit

	colord? ( x11-misc/colord:= )
	fcitx? ( app-i18n/fcitx-configtool )
	i18n? ( app-i18n/ibus )
	input_devices_wacom? (
		dev-libs/libwacom
		x11-drivers/xf86-input-wacom )
	smartcard? ( dev-libs/nss )
	udev? (
		dev-libs/libgudev:=
		virtual/libudev:= )"
RDEPEND="${DEPEND}
	gnome-base/dconf
	x11-themes/gnome-themes-standard
	x11-themes/adwaita-icon-theme
	!<gnome-base/gnome-control-center-2.22
	!<gnome-extra/gnome-color-manager-3.1.1
	!<gnome-extra/gnome-power-manager-3.1.3"
BDEPEND="dev-libs/libxml2:2
	sys-devel/gettext
	dev-util/intltool
	virtual/pkgconfig
	x11-base/xorg-proto"

S="${WORKDIR}"

src_prepare() {
	# https://bugzilla.gnome.org/show_bug.cgi?id=621836
	# Apparently this change severely affects touchpad usability for some
	# people, so revert it if USE=short-touchpad-timeout.
	# Revisit if/when upstream adds a setting for customizing the timeout.
	use short-touchpad-timeout \
		&& eapply "${FILESDIR}/${PN}-3.7.90-short-touchpad-timeout.patch"

	# Make colord and wacom optional; requires eautoreconf
	eapply "${FILESDIR}/01_${PN}-optional-color-wacom.patch"

	# pnp.ids is not provided by >=gnome-base/gnome-desktop-3.21.4 #
	#  use udev's hwdb to query PNP IDs instead #
	eapply "${FILESDIR}/02_${PN}-2021-optional-pnp-ids.patch"

	# Ensure libunity-settings-daemon.so.1 gets linked to libudev.so #
	sed -i \
		-e 's:-lm :-lm -ludev :g' \
		gnome-settings-daemon/Makefile.am

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
		debian/user/unity-settings-daemon.service || die "Sed failed for debian/user/unity-settings-daemon.service"
}

src_configure() {
	append-ldflags -Wl,--warn-unresolved-symbols
	append-cflags -Wno-deprecated-declarations -I/usr/include/librsvg-2.0

	gnome2_src_configure \
		--disable-static \
		--enable-man \
		--disable-packagekit \
		$(use_enable colord color) \
		$(use_enable debug) \
		$(use_enable debug more-warnings) \
		$(use_enable fcitx) \
		$(use_enable i18n ibus) \
		$(use_enable nls) \
		$(use_enable smartcard smartcard-support) \
		$(use_enable udev gudev) \
		$(use_enable udev) \
		$(use_enable input_devices_wacom wacom)
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

src_test() {
	Xemake check
}
