# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{8..10} )

UVER=""
UREV="5build4"

inherit gnome2 distutils-r1 ubuntu-versionator

DESCRIPTION="Simple on-screen Keyboard with macros and easy layout creation"
HOMEPAGE="https://launchpad.net/onboard"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.debian.tar.xz"

LICENSE="GPL-2"
SLOT="0"
#KEYWORDS="~amd64"
IUSE=""

RDEPEND="app-accessibility/at-spi2-core
	app-text/iso-codes
	dev-libs/glib:2
	dev-libs/libappindicator
	$(python_gen_cond_dep '
		dev-python/dbus-python[${PYTHON_MULTI_USEDEP}]
		dev-python/pycairo[${PYTHON_MULTI_USEDEP}]
		dev-python/python-distutils-extra[${PYTHON_MULTI_USEDEP}]
	')
	gnome-base/dconf
	gnome-extra/mousetweaks
	media-libs/libcanberra
	x11-libs/cairo[svg]
	x11-libs/gdk-pixbuf
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXi
	x11-libs/libxkbfile
	x11-libs/pango"
