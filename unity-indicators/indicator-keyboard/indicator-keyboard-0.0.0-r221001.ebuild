# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
GNOME2_EAUTORECONF="yes"

UVER=+19.10.20220803
UREV=0ubuntu1

inherit gnome2 ubuntu-versionator vala

DESCRIPTION="Keyboard indicator used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/indicator-keyboard"

LICENSE="GPL-3"
SLOT="0"
#KEYWORDS="~amd64"
IUSE="+charmap +fcitx"
RESTRICT="test"

COMMON_DEPEND="
	>=app-i18n/ibus-1.5.1[vala]
	>=dev-libs/libgee-0.8.3:0.8
	>=gnome-base/gnome-desktop-3.17.92:3=
	gnome-base/libgnomekbd
	>=sys-apps/accountsservice-0.6.40
	>=x11-libs/gtk+-3.1.6:3
	>=x11-misc/lightdm-1.1.3

	fcitx? ( >=app-i18n/fcitx-4.2.9.5[introspection] )
"
RDEPEND="${COMMON_DEPEND}
	>=dev-libs/glib-2.37.5:2
	dev-libs/libindicator:3
	gnome-base/dconf
	>=sys-libs/glibc-2.4
	>=x11-libs/cairo-1.2.4
	>=x11-libs/libxklavier-5.1
	>=x11-libs/pango-1.18.0

	charmap? ( gnome-extra/gucharmap:2.90 )
"
DEPEND="${COMMON_DEPEND}
	dev-libs/gobject-introspection
	sys-apps/dbus
	sys-apps/systemd
	x11-apps/xauth

	$(vala_depend)
"

S="${WORKDIR}"

PATCHES=( "${FILESDIR}"/"${PN}"-optional-fcitx.patch )

src_prepare() {
	use charmap || ( sed -i \
		-e "/Character Map/d" \
		lib/indicator-menu.vala || die )

	# Disable tests #
	sed -i \
		-e "s/ tests//" \
		Makefile.am || die

	ubuntu-versionator_src_prepare
}

src_configure() {
	econf $(use_enable fcitx)
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
