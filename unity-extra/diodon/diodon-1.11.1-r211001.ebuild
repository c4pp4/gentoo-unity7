# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

UVER=""
UREV="1"

inherit meson ubuntu-versionator vala xdg

DESCRIPTION="GTK+ Clipboard manager"
HOMEPAGE="https://launchpad.net/diodon"
SRC_URI="${UURL}.orig.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+indicator scope"

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

S="${S%1}0"

src_prepare() {
	# Revert dependency to deprecated appindicator #
	sed -i \
		-e "/appindicator_dep/{s/ayatana-//}" \
		-e "/appindicator_dep/{s/0.5.3/0.3.0/}" \
		meson.build

	ubuntu-versionator_src_prepare
}

src_configure() {
	local emesonargs=(
		$(meson_use !indicator disable-indicator-plugin)
		$(meson_use scope enable-unity-scope)
	)
	meson_src_configure
}
