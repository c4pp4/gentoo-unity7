# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{8..10} )

URELEASE="impish"
inherit distutils-r1 ubuntu-versionator udev

UVER_PREFIX="+21.04.${PVR_MICRO}"

DESCRIPTION="Utility to write and run integration tests easily"
HOMEPAGE="https://launchpad.net/autopilot"
SRC_URI="${UURL}/${MY_P}${UVER_PREFIX}.orig.tar.gz
	${UURL}/${MY_P}${UVER_PREFIX}-${UVER}.diff.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
RESTRICT="mirror"

RDEPEND="app-i18n/ibus[introspection]
	dev-libs/glib:2
	dev-python/dbus-python[${PYTHON_USEDEP}]
	dev-python/pyjunitxml
	dev-python/pyxdg[${PYTHON_USEDEP}]
	dev-python/python-xlib
	dev-python/testtools[${PYTHON_USEDEP}]
	dev-util/lttng-ust
	gnome-extra/zeitgeist
	unity-base/compiz
	x11-libs/gtk+:3[introspection]"
DEPEND="${RDEPEND}"

S="${WORKDIR}"

src_prepare() {
	ubuntu-versionator_src_prepare
	default
}

src_install() {
	default

	local udevdir="$(get_udevdir)"
	insinto ${udevdir}/rules.d
	doins debian/61-autopilot3-uinput.rules
}
