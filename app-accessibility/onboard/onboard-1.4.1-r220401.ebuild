# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{8..10} )

UVER=""
UREV="5build4"

inherit gnome2 distutils-r1 ubuntu-versionator

DESCRIPTION="Simple on-screen Keyboard with macros and easy layout creation"
HOMEPAGE="https://launchpad.net/onboard"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.debian.tar.xz"

LICENSE="GPL-3+ BSD"
SLOT="0"
#KEYWORDS="~amd64"
IUSE="wayland"

BDEPEND="
	>=dev-libs/glib-2.31.8:2
	$(python_gen_cond_dep '
		dev-python/dbus-python[${PYTHON_USEDEP}]
		dev-python/pycairo[${PYTHON_USEDEP}]
		dev-python/pygobject[${PYTHON_USEDEP}]
		>=dev-python/python-distutils-extra-2.10[${PYTHON_USEDEP}]
	')
	virtual/udev
"
DEPEND="
	app-text/hunspell:=
	app-text/iso-codes
	>=gnome-base/dconf-0.14.0
	gnome-base/librsvg
	>=media-libs/libcanberra-0.2
	>=sys-libs/glibc-2.29
	>=x11-libs/cairo-1.10.0[svg]
	x11-libs/gdk-pixbuf
	>=x11-libs/gtk+-3.9.10:3[introspection]
	x11-libs/libX11
	>=x11-libs/libXi-1.2.99.4
	>=x11-libs/libxkbfile-1.1.0
	x11-libs/libXtst
	>=x11-libs/pango-1.29.3

	wayland? ( dev-libs/wayland )
"
RDEPEND="
	app-accessibility/at-spi2-core
	dev-libs/libappindicator:3
	>=gnome-extra/mousetweaks-3.3.90
	x11-misc/xdg-utils
"
