# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

URELEASE="impish"
inherit autotools flag-o-matic gnome2 virtualx ubuntu-versionator xdg-utils

UVER_PREFIX="+${UVER_RELEASE}.${PVR_MICRO}"

DESCRIPTION="Unity Settings Daemon"
HOMEPAGE="https://launchpad.net/unity-settings-daemon"
SRC_URI="${UURL}/${MY_P}${UVER_PREFIX}.orig.tar.gz
	${UURL}/${MY_P}${UVER_PREFIX}-${UVER}.diff.gz"

LICENSE="GPL-2"
SLOT="0"
IUSE="+colord debug +fcitx +i18n +input_devices_wacom nls +short-touchpad-timeout smartcard +udev"
KEYWORDS="~amd64"
REQUIRED_USE="input_devices_wacom? ( udev )
		smartcard? ( udev )"
RESTRICT="mirror"

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
	>=sys-apps/systemd-232
	>=sys-power/upower-0.99:=
	unity-base/gsettings-ubuntu-touch-schemas
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
		sys-apps/hwids
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
	# Ubuntu patchset #
	eapply "${WORKDIR}/${MY_P}${UVER_PREFIX}-${UVER}.diff"  # This needs to be applied for the debian/ directory to be present #

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

	# Ensure libunity-settings-daemon.so.1 gets linked to libudev.so #
	sed -i \
		-e 's:-lm :-lm -ludev :g' \
		gnome-settings-daemon/Makefile.am

	# Disable all language files as they can be incomplete #
	#  due to being provided by Ubuntu's language-pack packages #
	> po/LINGUAS

	eautoreconf
	gnome2_src_prepare
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

src_compile() {
	gnome2_src_compile
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

	find "${D}" -name "*.la" -delete || die
}

src_test() {
	Xemake check
}

pkg_preinst() {
	# Modified gnome2_schemas_savelist to find *.gschema.override files #
	export GNOME2_ECLASS_GLIB_SCHEMAS=$(find "${ED}/usr/share/glib-2.0/schemas" -name "*.gschema.override" 2>/dev/null)
}

pkg_postinst() {
	gnome2_schemas_update
	xdg_icon_cache_update
	ubuntu-versionator_pkg_postinst
}

pkg_postrm() {
	gnome2_schemas_update
	xdg_icon_cache_update
}
