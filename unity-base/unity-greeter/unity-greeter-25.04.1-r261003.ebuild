# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
GNOME2_EAUTORECONF="yes"

UVER=
UREV=0ubuntu1

inherit ubuntu-versionator gnome2 vala

DESCRIPTION="LightDM greeter (login screen) for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/unity-greeter"
SRC_URI="${UURL}-${UREV}.tar.xz"
S="${WORKDIR}/${PN}-24.10.1"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="nls +ready-sound systemd"
RESTRICT="test"

COMMON_DEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	>=dev-libs/ido-13.10.0:0=
	>=dev-libs/libindicator-0.4.90:3
	>=media-libs/libcanberra-gtk3-0.2
	>=unity-base/unity-settings-daemon-15.04.1
	>=x11-libs/gtk+-3.16.2:3
	>=x11-misc/lightdm-1.20.0[vala]
"
RDEPEND="${COMMON_DEPEND}
	>=app-eselect/eselect-lightdm-0.1
	>=dev-libs/glib-2.43.92:2
	gnome-base/dconf
	gnome-extra/nm-applet[appindicator]
	|| (
		media-fonts/fonts-ubuntu
		media-fonts/ubuntu-font-family
	)
	sys-auth/polkit
	unity-indicators/indicator-application
	unity-indicators/indicator-datetime
	unity-indicators/indicator-keyboard
	unity-indicators/indicator-power
	unity-indicators/indicator-session
	unity-indicators/indicator-sound
	x11-apps/xhost
	x11-apps/xrandr
	>=x11-libs/cairo-1.10.0[glib]
	>=x11-libs/gdk-pixbuf-2.22.0:2
	x11-libs/libX11
	x11-libs/libXext
	>=x11-libs/pango-1.14.0
	x11-misc/notify-osd
	x11-themes/humanity-icon-theme

	ready-sound? ( x11-themes/ubuntu-sounds )
	systemd? ( sys-apps/systemd )
"
DEPEND="${COMMON_DEPEND}
	media-libs/freetype:2
	x11-libs/pixman
"
BDEPEND="
	acct-group/polkitd
	dev-util/intltool
	virtual/pkgconfig

	$(vala_depend)
"

PATCHES=(
	"${FILESDIR}"/environment-variables-and-indicators.patch # Fix environment variables, start indicators without systemd
	"${FILESDIR}"/quit-unity-greeter-immediately-on-active-session-login.patch
	"${FILESDIR}"/rename-ubuntu-session-to-unity.diff
	"${FILESDIR}"/start-notify-osd.patch
)

src_prepare() {
	# Panel icon size and padding #
	sed -i \
		-e "/entry.image.show.connect/i entry.image.set_pixel_size(22);" \
		-e "/hbox.pack_start (entry.image/{s/0/3/}" \
		"${S}"/src/menubar.vala || die

	# Disable all language files as they can be incomplete #
	#  due to being provided by Ubuntu's language-pack packages #
	> po/LINGUAS

	ubuntu-versionator_src_prepare
}

src_configure() {
	local myeconfargs=(
		$(use_enable nls)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default

	local \
		gschema="10_ubuntu-${PN}.gschema.override" \
		gschema_dir="/usr/share/glib-2.0/schemas"

	insinto "${gschema_dir}"
	newins "${FILESDIR}"/ubuntu-${PN}.gsettings-override \
		"${gschema}"

	insinto /usr/share/${PN}
	newins "${FILESDIR}/branding/gentoo_logo.png" logo.png
	# Hide centered logo on secondary monitors (transparent 1x1 px image) #
	newins "${FILESDIR}/branding/empty_cof.png" cof.png

	if use ready-sound; then
		sed -i \
			-e "/play-ready-sound/d" \
			"${ED}${gschema_dir}/${gschema}" || die
	fi

	# Install polkit privileges config #
	insinto /var/lib/polkit-1/localauthority/10-vendor.d
	doins debian/${PN}.pkla
	fowners root:polkitd /var/lib/polkit-1/localauthority/10-vendor.d/${PN}.pkla

	insinto /usr/share/polkit-1/rules.d
	newins debian/01-${PN}.rules 01-${PN}.rules

	find "${ED}" -name '*.la' -delete || die
}

pkg_postinst() {
	elog "Setting '${PN}' as default greeter of LightDM."
	"${EROOT}"/usr/bin/eselect lightdm set unity-greeter

	ubuntu-versionator_pkg_postinst
}
