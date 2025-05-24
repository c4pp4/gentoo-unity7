# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_EXT=1
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..14} )

UVER=
UREV=10

inherit gnome2 distutils-r1 ubuntu-versionator

DESCRIPTION="Simple on-screen Keyboard with macros and easy layout creation"
HOMEPAGE="https://launchpad.net/onboard"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.debian.tar.xz"

LICENSE="GPL-3+ BSD"
SLOT="0"
KEYWORDS="amd64"
IUSE="+accessibility debug wayland"
RESTRICT="test"

COMMON_DEPEND="
	>=app-text/hunspell-1.7
	app-text/iso-codes
	>=gnome-base/dconf-0.14.0
	gnome-base/gsettings-desktop-schemas
	>=media-libs/libcanberra-0.2
	>=sys-apps/systemd-183
	>=x11-libs/gtk+-3.9.10:3[introspection]
	>=x11-libs/libxkbfile-1.1.0
	x11-libs/libXtst

	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/dbus-python[${PYTHON_USEDEP}]
		dev-python/pycairo[${PYTHON_USEDEP}]
	')
"
RDEPEND="${COMMON_DEPEND}
	>=dev-libs/glib-2.31.8:2
	dev-libs/libappindicator:3
	gnome-base/librsvg
	>=sys-devel/gcc-5.2
	>=sys-libs/glibc-2.29
	>=x11-libs/cairo-1.10.0
	x11-libs/gdk-pixbuf:2[introspection]
	x11-libs/libX11
	>=x11-libs/libXi-1.2.99.4
	>=x11-libs/pango-1.29.3[introspection]

	accessibility? (
		app-accessibility/at-spi2-core:2
		gnome-extra/mousetweaks
	)
"
DEPEND="${COMMON_DEPEND}
	wayland? ( dev-libs/wayland )

	$(python_gen_cond_dep '
		dev-python/python-distutils-extra[${PYTHON_USEDEP}]
	')
"

src_install() {
	distutils-r1_src_install

	# Fix /etc/xdg/autostart path #
	mv "${ED}/$(python_get_sitedir)"/etc "${ED}" || die
}
