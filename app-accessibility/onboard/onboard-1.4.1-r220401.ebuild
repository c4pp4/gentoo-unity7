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
IUSE="+accessibility wayland"

COMMON_DEPEND="
	>=app-text/hunspell-1.7
	>=gnome-base/dconf-0.14.0
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
	app-text/iso-codes
	>=dev-libs/glib-2.31.8:2
	dev-libs/libappindicator:3
	gnome-base/librsvg
	>=sys-devel/gcc-5.2
	>=sys-libs/glibc-2.29
	>=x11-libs/cairo-1.10.0[svg]
	x11-libs/gdk-pixbuf:2[introspection]
	x11-libs/libX11
	>=x11-libs/libXi-1.2.99.4
	>=x11-libs/pango-1.29.3[introspection]

	accessibility? (
		app-accessibility/at-spi2-core:2
		gnome-extra/mousetweaks
	)

	$(python_gen_cond_dep '
		dev-python/dbus-python[${PYTHON_USEDEP}]
	')
"
DEPEND="${COMMON_DEPEND}
	wayland? ( dev-libs/wayland )

	$(python_gen_cond_dep '
		>=dev-python/python-distutils-extra-2.10[${PYTHON_USEDEP}]
	')
"
