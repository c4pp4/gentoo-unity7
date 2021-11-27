# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{8..10} )

UVER=""
UREV="1build1"

inherit distutils-r1 ubuntu-versionator

DESCRIPTION="System tray application for weather status information"
HOMEPAGE="https://github.com/dglent/meteo-qt"

LICENSE="GPL-3"
SLOT="0"
#KEYWORDS="~amd64"
IUSE=""

RDEPEND="dev-python/PyQt5[${PYTHON_USEDEP}]
	dev-python/lxml[${PYTHON_USEDEP}]
	dev-python/sip[${PYTHON_USEDEP}]
	dev-python/urllib3[${PYTHON_USEDEP}]"
DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"

python_install_all() {
	distutils-r1_python_install_all
	rm -r "${ED}/usr/share/doc/${PN}"
}
