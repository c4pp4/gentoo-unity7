# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
GNOME2_EAUTORECONF="yes"

UVER="+20.04.20200312"
UREV="0ubuntu3"

inherit gnome2 ubuntu-versionator vala

DESCRIPTION="The greeter (login screen) application for Unity. It is implemented as a LightDM greeter."
HOMEPAGE="https://launchpad.net/unity-greeter"
SRC_URI="${UURL}-${UREV}.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+accessibility +battery +branding +networkmanager nls +sound"

DEPEND="dev-libs/libindicator
	gnome-base/gnome-desktop:3=
	media-libs/freetype:2
	media-libs/libcanberra
	unity-base/unity-settings-daemon
	unity-indicators/ido
	x11-libs/cairo
	x11-libs/gtk+:3
	>=x11-misc/lightdm-1.4.0
	$(vala_depend)"

RDEPEND="accessibility? ( app-accessibility/onboard
			app-accessibility/orca )
	battery? ( unity-indicators/indicator-power )
	networkmanager? ( >=gnome-extra/nm-applet-0.9.8.0 )
	sound? ( unity-indicators/indicator-sound )
	>=app-eselect/eselect-lightdm-0.1
	>=gnome-base/gsettings-desktop-schemas-3.8
	media-fonts/ubuntu-font-family
	sys-auth/polkit-pkla-compat
	unity-base/unity-language-pack
	unity-indicators/indicator-session
	unity-indicators/indicator-datetime
	unity-indicators/indicator-application
	x11-apps/xrandr
	x11-themes/ubuntu-wallpapers"

S="${S}${UVER}"

src_prepare() {
	# Import DISPLAY and XDG_SESSION_CLASS1, set XDG_CURRENT_DESKTOP #
	eapply "${FILESDIR}"/environment-variables.patch

	# Patch 'at-spi-bus-launcher' path #
	sed -i \
		-e "s:/usr/lib/at-spi2-core/at-spi-bus-launcher:/usr/libexec/at-spi-bus-launcher:" \
		"${S}"/src/unity-greeter.vala || die

	use battery || sed -i \
		-e "s/ indicator-power//" \
		src/unity-greeter.vala

	use networkmanager || sed -i \
		-e "/command_line_async (\"nm-applet\")/d" \
		src/unity-greeter.vala

	if use sound; then
		sed -i \
			-e "s/\"system-ready\"/\"dialog-question\"/" \
			src/unity-greeter.vala
	else
		sed -i \
			-e "s/ indicator-sound//" \
			src/unity-greeter.vala
	fi

	# Disable all language files as they can be incomplete #
	#  due to being provided by Ubuntu's language-pack packages #
	> po/LINGUAS

	ubuntu-versionator_src_prepare
}

src_configure() {
	econf $(use_enable nls)
}

src_install() {
	default

	local \
		gschema="10_unity-greeter.gschema.override" \
		gschema_dir="/usr/share/glib-2.0/schemas"

	insinto "${gschema_dir}"
	newins "${FILESDIR}"/unity-greeter.gsettings-override \
		"${gschema}"

	insinto /usr/share/unity-greeter
	if use branding; then
		newins "${FILESDIR}/branding/gentoo_logo.png" logo.png
		newins "${FILESDIR}/branding/gentoo_cof.png" cof.png # Gentoo logo for multi monitor usage #
	else
		"${S}"/src/logo-generator --logo "${S}"/data/logo-bare.png --text " ${URELEASE% *}" --output logo.png
		doins "${S}/logo.png"
	fi

	use sound && sed -i \
		-e "/play-ready-sound/d" \
		"${ED}${gschema_dir}/${gschema}"

	# Remove schema override if it's not used #
	use sound && use branding && sed -i \
		-e "/com.canonical.unity-greeter:unity-greeter/,+1 d" \
		"${ED}${gschema_dir}/${gschema}"

	# Install polkit privileges config #
	insinto /var/lib/polkit-1/localauthority/10-vendor.d
	doins debian/unity-greeter.pkla
	fowners root:polkitd /var/lib/polkit-1/localauthority/10-vendor.d/unity-greeter.pkla

	find "${ED}" -name '*.la' -delete || die
}

pkg_postinst() {
	elog "Setting ${PN} as default greeter of LightDM."
	"${ROOT}"/usr/bin/eselect lightdm set unity-greeter

	elog "Setting 'unity' as default user session."
	if line=$(grep -s -m 1 -e "user-session" "/etc/lightdm/lightdm.conf"); then
		sed -i -e "s/user-session=.*/user-session=unity/" "/etc/lightdm/lightdm.conf"
	else
		echo "user-session=unity" >> "${EROOT}/etc/lightdm/lightdm.conf"
	fi
	ubuntu-versionator_pkg_postinst
}

pkg_postrm() {
	if [ -e /usr/libexec/lightdm/lightdm-set-defaults ]; then
		elog "Removing ${PN} as default greeter of LightDM"
		/usr/libexec/lightdm/lightdm-set-defaults --remove --greeter=${PN}
		/usr/libexec/lightdm/lightdm-set-defaults --remove --session=unity
	fi
	gnome2_pkg_postrm
}
