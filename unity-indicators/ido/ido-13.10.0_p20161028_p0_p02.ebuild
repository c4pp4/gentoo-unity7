# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

URELEASE="impish"
inherit autotools eutils flag-o-matic ubuntu-versionator vala

UVER_PREFIX="+17.04.${PVR_MICRO}"

DESCRIPTION="Widgets and other objects used for indicators by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/ido"
SRC_URI="${UURL}/${MY_P}${UVER_PREFIX}.orig.tar.gz
	 ${UURL}/${MY_P}${UVER_PREFIX}-${UVER}.diff.gz"

LICENSE="LGPL-2.1 LGPL-3"
SLOT="0/0.0.0"
KEYWORDS="~amd64"
IUSE=""
RESTRICT="mirror"

DEPEND=">=dev-libs/glib-2.37
	x11-libs/gtk+:3
	$(vala_depend)"

S="${WORKDIR}"

src_prepare() {
	ubuntu-versionator_src_prepare
	vala_src_prepare
	export VALA_API_GEN="$VAPIGEN"
	eautoreconf
}

src_install() {
	default
	prune_libtool_files
}
