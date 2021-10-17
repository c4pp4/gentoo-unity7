# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{8..10} )

inherit gnome2-utils

DESCRIPTION="Network speed indicator for Unity"
HOMEPAGE="https://github.com/GGleb/indicator-netspeed-unity"

MY_PN="indicator-netspeed-unity"
COMMIT="41a9b524efc767a8990532667a92748235ed6917"
SRC_URI="https://github.com/GGleb/${MY_PN}/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
RESTRICT="mirror"

DEPEND="net-analyzer/nethogs"

S="${WORKDIR}/${MY_PN}-${COMMIT}"

src_prepare() {
	sed -i \
		-e "s/-s ${MY_PN}/${MY_PN}/" \
		Makefile
	default
}

pkg_preinst() {
	gnome2_schemas_savelist
}

pkg_postinst() {
	gnome2_schemas_update
}

pkg_postrm() {
	gnome2_schemas_update
}
