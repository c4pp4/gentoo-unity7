# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{7..9} )

inherit distutils-r1 gnome2-utils ubuntu-versionator xdg-utils

DESCRIPTION="Indicator to change user privacy settings"
HOMEPAGE="http://www.florian-diesch.de/software/indicator-privacy"
SRC_URI="http://www.florian-diesch.de/software/indicator-privacy/dist/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="dev-libs/libappindicator
	dev-libs/glib:2
	dev-python/pygobject:3
	dev-python/pyxdg
	gnome-extra/zeitgeist
	dev-libs/geoip
	x11-libs/gtk+:3[introspection]"
DEPEND="${RDEPEND}"
RESTRICT="mirror"

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
