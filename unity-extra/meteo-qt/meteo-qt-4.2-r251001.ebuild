# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..14} )

UVER=
UREV=2

inherit distutils-r1 xdg ubuntu-versionator

DESCRIPTION="System tray application for weather status information"
HOMEPAGE="https://github.com/dglent/meteo-qt"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="test"

COMMON_DEPEND="
	${PYTHON_DEPS}
	$(python_gen_cond_dep 'dev-python/pyqt6[${PYTHON_USEDEP}]')
"
RDEPEND="${COMMON_DEPEND}
	dev-qt/qttranslations:6

	$(python_gen_cond_dep 'dev-python/lxml[${PYTHON_USEDEP}]')
"
DEPEND="${COMMON_DEPEND}
	dev-qt/qttools:6
"

src_prepare() {
	# Fix lrelease path, data_dir and doc #
	sed -i \
		-e "s:lrelease-pro-qt6:/usr/$(get_libdir)/qt6/bin/lrelease:" \
		-e "s:/usr/share/applications:share/applications:" \
		-e "s:/usr/share/icons:share/icons:" \
		-e "s:/usr/share/meteo_qt/translations:share/meteo_qt/translations:" \
		-e "s:/usr/share/doc/meteo-qt:share/doc/${PF}:" \
		-e "/include_package_data/{s/True/False/}" \
		setup.py || die

	ubuntu-versionator_src_prepare
}
