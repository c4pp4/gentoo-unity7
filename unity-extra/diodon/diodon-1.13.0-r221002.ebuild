# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=1

inherit meson vala xdg ubuntu-versionator

DESCRIPTION="GTK+ Clipboard manager"
HOMEPAGE="https://launchpad.net/diodon"
SRC_URI="${UURL}.orig.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE="+indicator scope test"
RESTRICT="!test? ( test )"

COMMON_DEPEND="
	>=dev-libs/glib-2.46:2
	>=dev-libs/libpeas-1.1.1
	>=gnome-extra/zeitgeist-0.9.14
	>=x11-libs/gtk+-3.22:3[introspection]
	>=x11-libs/libXtst-1.2.0

	indicator? ( >=dev-libs/libayatana-appindicator-0.5.3 )
	scope? ( >=unity-base/unity-7.1.0 )
"
RDEPEND="${COMMON_DEPEND}
	gnome-base/dconf
	>=sys-libs/glibc-2.14
	>=x11-libs/gdk-pixbuf-2.22.0:2[introspection]
	x11-libs/libX11
"
DEPEND="${COMMON_DEPEND}
	dev-libs/gobject-introspection
	dev-util/desktop-file-utils
	x11-apps/xauth

	test? ( x11-misc/xvfb-run )

	$(vala_depend)
"

src_prepare() {
	# Make test optional #
	use test || sed -i \
		-e "/testdatadir/d" \
		-e "/xvfb_run/d" \
		-e "/subdir('tests')/d" \
		meson.build || die

	ubuntu-versionator_src_prepare
}

src_configure() {
	local emesonargs=(
		$(meson_use !indicator disable-indicator-plugin)
		$(meson_use scope enable-unity-scope)
	)
	meson_src_configure
}
