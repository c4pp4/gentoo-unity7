# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{8..10} )
DISTUTILS_SINGLE_IMPL=1

URELEASE="impish"
inherit gnome2-utils distutils-r1 ubuntu-versionator xdg-utils

UVER="-${PVR_MICRO}build${PVR_PL_MAJOR}"

DESCRIPTION="Simple on-screen Keyboard with macros and easy layout creation"
HOMEPAGE="https://launchpad.net/onboard"
SRC_URI="${UURL}/${MY_P}.orig.tar.gz
	${UURL}/${MY_P}${UVER}.debian.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RESTRICT="mirror"

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

pkg_setup() {
	ubuntu-versionator_pkg_setup
	python-single-r1_pkg_setup
}

src_prepare() {
	ubuntu-versionator_src_prepare
	distutils-r1_src_prepare
}

src_install() {
	distutils-r1_src_install
}

pkg_preinst() {	gnome2_schemas_savelist; }

pkg_postinst() {
	gnome2_schemas_update
	xdg_icon_cache_update
	ubuntu-versionator_pkg_postinst
}

pkg_postrm() {
	gnome2_schemas_update
	xdg_icon_cache_update
}
