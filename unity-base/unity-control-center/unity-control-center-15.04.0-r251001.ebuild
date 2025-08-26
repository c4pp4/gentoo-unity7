# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
GNOME2_EAUTORECONF="yes"

UVER=+23.04.20230220
UREV=0ubuntu11

inherit gnome2 ubuntu-versionator vala

DESCRIPTION="Unity Desktop Configuration Tool"
HOMEPAGE="https://wiki.ubuntu.com/Unity"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+accessibility +bluetooth +colord +cups +gnome-online-accounts +input_devices_wacom +kerberos +networkmanager +v4l wayland +webkit"
RESTRICT="test"

COMMON_DEPEND="
	>=app-i18n/ibus-1.5.1[vala]
	>=dev-libs/glib-2.39.91:2
	>=dev-libs/libpwquality-1.1.0
	>=dev-libs/libtimezonemap-0.4.5
	>=dev-libs/libxml2-2.7.4:2
	dev-util/desktop-file-utils
	>=gnome-base/gnome-desktop-3.27.3:3=
	>=gnome-base/gnome-menus-3.2.0.1:3
	>=gnome-base/gsettings-desktop-schemas-3.15.4
	>=gnome-base/libgnomekbd-3.5.90
	>=gnome-base/libgtop-2.22.3:2=
	>=media-libs/libcanberra-0.25[pulseaudio]
	>=media-libs/libcanberra-gtk3-0.25
	>=media-libs/libpulse-2.0[glib]
	>=net-libs/geonames-0.1
	>=sys-apps/accountsservice-0.6.34
	sys-auth/polkit[gtk]
	>=sys-libs/glibc-2.4
	>=sys-power/upower-0.99.1:=
	>=unity-base/unity-settings-daemon-15.04.1[colord?,input_devices_wacom?]
	unity-indicators/indicator-datetime
	>=x11-libs/gdk-pixbuf-2.23.0:2
	>=x11-libs/gtk+-3.16.2:3
	>=x11-libs/libnotify-0.7.3:=
	x11-libs/libX11

	colord? ( >=x11-misc/colord-1.4.3:=[vala] )
	cups? ( >=net-print/cups-1.6.0 )
	gnome-online-accounts? ( <net-libs/gnome-online-accounts-3.49.0 )
	input_devices_wacom? ( >=dev-libs/libwacom-1.1 )
	kerberos? ( >=app-crypt/mit-krb5-1.8 )
	networkmanager? (
		>=net-libs/libnma-1.2.0[vala]
		>=net-misc/modemmanager-0.7.991[vala]
		>=net-misc/networkmanager-1.2.0[vala]
	)
	v4l? ( >=media-video/cheese-3.18.0 )
	webkit? ( >=net-libs/webkit-gtk-2.15.1:4.1 )
"
RDEPEND="${COMMON_DEPEND}
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-text/iso-codes
	gnome-extra/polkit-gnome
	>=media-libs/fontconfig-2.12.6:1.0
	media-libs/libglvnd
	>=unity-base/gsettings-ubuntu-touch-schemas-0.0.1
	>=x11-libs/cairo-1.10.0
	>=x11-libs/libXi-1.2.99.4
	>=x11-libs/pango-1.18.0
	x11-themes/adwaita-icon-theme

	accessibility? ( gnome-extra/mousetweaks )
	cups? (
		app-admin/system-config-printer
		net-print/cups-pk-helper
	)
	wayland? ( >=dev-libs/wayland-1.0.2 )
"
DEPEND="${COMMON_DEPEND}
	>=dev-libs/dbus-glib-0.32
	dev-libs/libxslt
	dev-util/gtk-doc
	gnome-base/gnome-common
	|| (
		media-fonts/fonts-ubuntu
		media-fonts/ubuntu-font-family
	)
	>=sys-apps/dbus-0.32
	>=x11-libs/libXft-2.1.2
	x11-libs/libxkbfile
	>=x11-libs/libxklavier-5.1

	bluetooth? ( net-wireless/gnome-bluetooth:3= )

	$(vala_depend)
"
BDEPEND=">=dev-util/intltool-0.37.1"
PDEPEND="
	gnome-extra/activity-log-manager

	bluetooth? ( unity-indicators/indicator-bluetooth )
"

S="${WORKDIR}"

PATCHES=(
	"${FILESDIR}"/01-langselector.patch # Based on g-c-c v3.24 Region & Language panel
	"${FILESDIR}"/02-optional-bt-colord-kerberos-wacom.patch
	"${FILESDIR}"/03-revert-searching-the-dash-legal-notice.patch
	"${FILESDIR}"/04-ibus_init.patch
	"${FILESDIR}"/fix-sharing-panel-translation.patch
)

src_prepare() {
	use cups && eapply "${FILESDIR}"/printers-fix_launcher.patch

	if use gnome-online-accounts; then
		# Needed by gnome-extra/gnome-calendar #
		eapply "${FILESDIR}"/online-accounts-enable_passing_data.patch

		# Use .desktop Comment from g-c-c we can translate #
		sed -i \
			-e "/Comment/{s/your online accounts/to your online accounts and decide what to use them for/}" \
			panels/online-accounts/unity-online-accounts-panel.desktop.in.in || die
	fi

	# Branding #
	cp "${FILESDIR}"/branding/UnityLogo.svg panels/info/GnomeLogoVerticalMedium.svg || die
	sed -i \
		-e 's/"distributor"/"release"/' \
		-e "s/%s.%s.%s/%s.%s.%s (%s)/" \
		-e "/%s.%s.%s/{s/micro/micro, data->distributor/}" \
		-e "/gtk_widget_hide (WID (\"version_label\")/d" \
		-e "s:gnome/gnome:unity/unity:" \
		panels/info/cc-info-panel.c || die
	sed -i \
		-e "s/UnityLogo.png/GnomeLogoVerticalMedium.svg/" \
		panels/info/info.ui || die

	# Fix hostname transliteration #
	sed -i \
		-e "/g_convert/,+6 d" \
		-e "s:ASCII \*/:ASCII */\n\tresult = g_str_to_ascii (pretty, NULL);:" \
		panels/info/hostname-helper.c || die
	grep -Fq "translit: '%s'" panels/info/hostname-helper.c || die

	# Rename button to be translated #
	sed -i \
		-e "s/_Add Profile…/Add profile/" \
		panels/network/network-ethernet.ui || die

	# Fix typo (Sha ring) #
	sed -i \
		-e "/Name=/{s/Sha­ring/Sharing/}" \
		panels/sharing/unity-sharing-panel.desktop.in.in || die

	# Fix metadata path #
	sed -i \
		-e "/appdatadir/{s/\/appdata/\/metainfo/}" \
		shell/appdata/Makefile.am || die

	# Rename cc-remote-login-helper as is provided by gnome-base/gnome-control-center #
	sed -i \
		-e "s/cc-remote-login-helper/ucc-remote-login-helper/g" \
		panels/sharing/{cc-remote-login.c,com.canonical.controlcenter.remote-login-helper.policy.in.in,Makefile.am} || die
	sed -i \
		-e "s/cc_remote_login_helper/ucc_remote_login_helper/g" \
		panels/sharing/Makefile.am || die
	mv panels/sharing/cc-remote-login-helper.c panels/sharing/ucc-remote-login-helper.c || die

	# Rename /usr/share/pixmaps/faces/ as is provided by gnome-base/gnome-control-center #
	sed -i \
		-e "s/faces/ucc-faces/" \
		panels/user-accounts/data/faces/Makefile.am || die
	sed -i \
		-e 's/"faces"/"ucc-faces"/' \
		panels/user-accounts/um-photo-dialog.c || die

	# Add legacy themes #
	sed -i \
		-e 's/\(themes_id\[] = {\)/\1 "Adwaita", "Ambiance", "Radiance", "HighContrast",/' \
		-e 's/\(themes_name\[] = {\)/\1 "Adwaita", "Ambiance", "Radiance", "High Contrast",/' \
		-e 's/\(colors_id\[] = {\)/\1 "Adwaita", "ubuntu-mono-dark", "ubuntu-mono-light", "HighContrast",/' \
		-e 's/\(colors_name\[] = {\)/\1 "Adwaita", "Ambiance", "Radiance", "High Contrast",/' \
		-e "/colors_name/{s/Default (Yaru)/Yaru/}" \
		-e "/colors_name/{s/Default (Yaru-dark)/Yaru-dark/}" \
		-e "s/prefer-light/default/" \
		panels/appearance/cc-appearance-panel.c || die

	# Revert button event background color #
	sed -i \
		-e "/GdkRGBA rgba/d" \
		-e "/gtk_widget_override_background_color/d" \
		shell/cc-shell-item-view.c || die

	# Disable all language files as they can be incomplete #
	#  due to being provided by Ubuntu's language-pack packages #
	> po/LINGUAS

	ubuntu-versionator_src_prepare
}

src_configure() {
	local mygnome2args=(
		--disable-update-mimedb
		--disable-static
		--enable-documentation
		--disable-fcitx
		--enable-ibus
		$(use_enable bluetooth)
		$(use_enable colord color)
		$(use_enable cups)
		$(use_enable input_devices_wacom wacom)
		$(use_enable kerberos)
		$(use_enable gnome-online-accounts onlineaccounts)
		$(use_with v4l cheese)
		$(use_enable webkit)
	)
	gnome2_src_configure "${mygnome2args[@]}"
}

src_install() {
	gnome2_src_install

	# Remove libgnome-bluetooth.so symlink #
	# as it's provided by net-wireless/gnome-bluetooth #
	rm "${ED}/usr/$(get_libdir)/libgnome-bluetooth.so" 2>/dev/null

	# If a .desktop file does not have inline #
	# translations, fall back to calling gettext #
	local f
	for f in "${ED}"/usr/share/applications/*.desktop; do
		echo "X-GNOME-Gettext-Domain=${PN}" >> "${f}"
	done
}

pkg_postinst() {
	ubuntu-versionator_pkg_postinst

	if use gnome-online-accounts; then
		echo
		ewarn "USE flag 'gnome-online-accounts' declared:"
		ewarn "Compatible $("${PORTAGE_QUERY_TOOL}" best_version / net-libs/gnome-online-accounts) package installed"
		ewarn "but it's not maintained and tested anymore."
		echo
	fi
	if ! use webkit; then
		echo
		elog "Searching in the dash - Legal notice:"
		elog "file:///usr/share/unity-control-center/searchingthedashlegalnotice.html"
		echo
	fi
}
