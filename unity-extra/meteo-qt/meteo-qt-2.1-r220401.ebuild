# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{8..10} )

UVER=
UREV=1build1

inherit distutils-r1 ubuntu-versionator

DESCRIPTION="System tray application for weather status information"
HOMEPAGE="https://github.com/dglent/meteo-qt"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="test"

COMMON_DEPEND="
	${PYTHON_DEPS}
	$(python_gen_cond_dep 'dev-python/PyQt5[${PYTHON_USEDEP}]')
"
RDEPEND="${COMMON_DEPEND}
	dev-qt/qttranslations

	$(python_gen_cond_dep '
		dev-python/lxml[${PYTHON_USEDEP}]
		dev-python/sip[${PYTHON_USEDEP}]
		dev-python/urllib3[${PYTHON_USEDEP}]
	')
"
DEPEND="${COMMON_DEPEND}
	dev-qt/linguist-tools
	dev-qt/qtcore
"

src_prepare() {
	# Fix lrelease path #
	sed -i "s:lrelease:/usr/$(get_libdir)/qt5/bin/lrelease:" setup.py || die

	# Fix docdir #
	sed -i "s:/doc/${PN}:/doc/${PF}:" setup.py || die

	ubuntu-versionator_src_prepare
}
