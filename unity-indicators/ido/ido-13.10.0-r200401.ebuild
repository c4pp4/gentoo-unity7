# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
UBUNTU_EAUTORECONF="yes"

UVER="+17.04.20161028"
UREV="0ubuntu2"

inherit vala ubuntu-versionator

DESCRIPTION="Widgets and other objects used for indicators by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/ido"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="LGPL-2.1 LGPL-3"
SLOT="0/0.0.0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=">=dev-libs/glib-2.37
	x11-libs/gtk+:3
	$(vala_depend)"

S="${WORKDIR}"

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
