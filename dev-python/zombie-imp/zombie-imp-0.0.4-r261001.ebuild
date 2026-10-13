# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..15} )

UVER=
UREV=2
MY_PN="python-zombie-imp"

inherit distutils-r1 ubuntu-versionator

DESCRIPTION="Copy of the 'imp' module that was removed in Python 3.12"
HOMEPAGE="
	https://github.com/encukou/zombie-imp
	https://pypi.org/project/zombie-imp/
"
SRC_URI="${UURL/${PN}/${MY_PN}}.orig.tar.gz"
S="${WORKDIR}/zombie_imp-${PV}"

LICENSE="PSF-2.4"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="test"
