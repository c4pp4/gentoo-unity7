# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{8..10} )

UVER=""
UREV="2build1"

inherit distutils-r1 ubuntu-versionator

DESCRIPTION="PyUnit extension for reporting in JUnit compatible XML"
HOMEPAGE="https://launchpad.net/pyjunitxml"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.debian.tar.xz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
RESTRICT="${RESTRICT} test"

S="${WORKDIR}/${P#py}"
