# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=1

inherit meson xdg ubuntu-versionator

DESCRIPTION="GUI Utility for logging into online accounts"
HOMEPAGE="https://github.com/xapp-project/gnome-online-accounts-gtk"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="test"

COMMON_DEPEND="
	>=dev-libs/glib-2.80.0:2
	>=net-libs/gnome-online-accounts-3.50
	>=sys-libs/glibc-2.34
	>=gui-libs/libadwaita-1.0.0:1
	>=gui-libs/gtk-4.0.0:4
"
RDEPEND="${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND}"

src_prepare() {
	# Make gnome-online-accounts-gtk appear in unity-control-center #
	sed -i \
		-e "/Categories/{s/Settings;/GNOME;GTK;Settings;DesktopSettings;X-Unity-Settings-Panel;X-GNOME-PersonalSettings;OnlineAccounts;\nX-Unity-Settings-Panel=online-accounts/}" \
		-e "/Icon/{s/${PN}/unity-online-accounts/}" \
		data/"${PN}".desktop.in.in || die

	# Translate window title #
	sed -i \
		-e 's/title">/title" translatable="yes">/' \
		src/online-accounts.ui || die

	ubuntu-versionator_src_prepare
}
