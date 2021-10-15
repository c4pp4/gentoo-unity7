# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{7..9} )

URELEASE="impish"
inherit distutils-r1 ubuntu-versionator

UVER="-${PVR_PL_MAJOR}build${PVR_PL_MINOR}"

DESCRIPTION="PyUnit extension for reporting in JUnit compatible XML"
HOMEPAGE="https://launchpad.net/pyjunitxml"
SRC_URI="${UURL}/${MY_P}${UVER_PREFIX}.orig.tar.gz
	${UURL}/${MY_P}${UVER_PREFIX}${UVER}.debian.tar.xz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
RESTRICT="mirror test"

S="${WORKDIR}/junitxml-${PV}"

src_prepare() {
	ubuntu-versionator_src_prepare
	default
}
