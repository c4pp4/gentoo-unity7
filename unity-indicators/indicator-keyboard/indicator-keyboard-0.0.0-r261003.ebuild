# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
GNOME2_EAUTORECONF="yes"

UVER=+19.10.20240924
UREV=0ubuntu4

inherit gnome2 systemd ubuntu-versionator vala

DESCRIPTION="Keyboard indicator used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/indicator-keyboard"
S="${S}${UVER}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="+charmap"
RESTRICT="test"

COMMON_DEPEND="
	>=app-i18n/ibus-1.5.1[vala]
	>=dev-libs/glib-2.37.5:2
	>=dev-libs/libgee-0.8.3:0.8
	>=gnome-base/gnome-desktop-3.17.92:3=
	gnome-base/libgnomekbd
	>=sys-apps/accountsservice-0.6.40:=
	>=x11-libs/cairo-1.2.4
	>=x11-libs/gtk+-3.1.6:3
	>=x11-libs/libxklavier-5.1
	>=x11-libs/pango-1.18.0
	>=x11-misc/lightdm-1.1.3[vala]
"
RDEPEND="${COMMON_DEPEND}
	dev-libs/libindicator:3
	gnome-base/dconf

	charmap? ( gnome-extra/gucharmap:2.90 )
"
DEPEND="${COMMON_DEPEND}"
BDEPEND="
	dev-libs/gobject-introspection
	virtual/pkgconfig

	$(vala_depend)
"

PATCHES=(
	"${FILESDIR}"/optional-fcitx.patch
	"${FILESDIR}"/Prevent-segfault-by-obtaining-style-context-associated-to-widget.patch
)

src_prepare() {
	if ! use charmap; then
		sed -i \
			-e "/Character Map/d" \
			lib/indicator-menu.vala || die
	fi

	# Disable tests #
	sed -i "s/ tests//" Makefile.am || die

	ubuntu-versionator_src_prepare

	# Install the systemd user unit even without sys-apps/systemd #
	sed -i \
		-e "s:^SYSTEMD_USERDIR=.*:SYSTEMD_USERDIR=$(systemd_get_userunitdir):" \
		configure || die
}

src_configure() {
	local myeconfargs=(
		--disable-fcitx
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die

	# Indicator service D-Bus activation (delegated to systemd if running) #
	insinto /usr/share/dbus-1/services
	doins "${FILESDIR}"/com.canonical.indicator.keyboard.service
}
