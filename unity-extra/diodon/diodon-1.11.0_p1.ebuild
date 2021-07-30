# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

URELEASE="hirsute"
inherit meson vala xdg ubuntu-versionator

UVER="-${PVR_MICRO}"

DESCRIPTION="GTK+ Clipboard manager"
HOMEPAGE="https://launchpad.net/diodon"
SRC_URI="${UURL}/${MY_P}.orig.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+indicator scope"
RESTRICT="mirror"

DEPEND=">=dev-libs/glib-2.46:2[dbus]
	>=dev-libs/libpeas-1.1.1[gtk]
	dev-util/desktop-file-utils
	>=gnome-extra/zeitgeist-0.9.14[introspection]
	x11-apps/xauth
	x11-base/xorg-server[xvfb]
	>=x11-libs/gtk+-3.22:3
	>=x11-libs/libXtst-1.2.0
	x11-misc/xvfb-run

	indicator? ( >=dev-libs/libappindicator-0.3.0:3 )
	scope? ( >=unity-base/unity-7.1.0 )

	$(vala_depend)"

src_prepare() {
	# Revert dependency to deprecated appindicator #
	sed -i \
		-e "/appindicator_dep/{s/ayatana-//}" \
		-e "/appindicator_dep/{s/0.5.3/0.3.0/}" \
		meson.build

	xdg_src_prepare
	vala_src_prepare
	default
}

src_configure() {
	local emesonargs=(
		$(meson_use !indicator disable-indicator-plugin)
		$(meson_use scope enable-unity-scope)
	)
	meson_src_configure
}
