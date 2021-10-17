# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{8..10} )

inherit distutils-r1 xdg

COMMIT="7ef91050cf3ccea2eeca13aefdbac29716806487"
SRC_URI="https://github.com/pulb/mailnag/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
KEYWORDS="~amd64"

DESCRIPTION="An extensible mail notification daemon"
HOMEPAGE="https://github.com/pulb/mailnag"

LICENSE="GPL-2"
SLOT="0"
IUSE="+messagingmenu"
RESTRICT="mirror"

BDEPEND="app-crypt/libsecret
	dev-libs/gobject-introspection
	dev-python/pygobject[${PYTHON_USEDEP}]
	dev-python/pyxdg[${PYTHON_USEDEP}]
	media-libs/gst-plugins-base:1.0
	>=net-misc/networkmanager-0.9.4
	x11-libs/gtk+:3
	>=x11-libs/libnotify-0.7"
RDEPEND="${BDEPEND}
	messagingmenu? ( x11-plugins/mailnag-messagingmenu-plugin )"

S="${WORKDIR}/${PN}-${COMMIT}"

python_install_all() {
	echo "X-GNOME-Gettext-Domain=mailnag" >> "${ED}"usr/share/applications/"${PN}"-config.desktop

	doman data/"${PN}".1
	doman data/"${PN}"-config.1

	distutils-r1_python_install_all
}
