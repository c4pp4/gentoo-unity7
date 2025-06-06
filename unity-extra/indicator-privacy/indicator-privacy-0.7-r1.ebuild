# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..14} )

inherit desktop gnome2 distutils-r1

DESCRIPTION="Indicator to change user privacy settings"
HOMEPAGE="https://www.florian-diesch.de/software/indicator-privacy"
SRC_URI="https://www.florian-diesch.de/software/indicator-privacy/dist/${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="mirror test"

COMMON_DEPEND="
	${PYTHON_DEPS}
	$(python_gen_cond_dep 'dev-python/pygobject:3[${PYTHON_USEDEP}]')
"
RDEPEND="${COMMON_DEPEND}
	dev-libs/geoip
	dev-libs/glib:2
	dev-libs/libappindicator:3
	gnome-base/dconf
	gnome-extra/zeitgeist[${PYTHON_SINGLE_USEDEP}]
	x11-libs/gtk+:3[introspection]

	$(python_gen_cond_dep '
		dev-python/pyxdg[${PYTHON_USEDEP}]
		>=unity-base/unity-7.0[${PYTHON_SINGLE_USEDEP}]
	')
"
DEPEND="${COMMON_DEPEND}
	$(python_gen_cond_dep '
		dev-python/python-distutils-extra[${PYTHON_USEDEP}]
	')
"
BDEPEND="dev-util/intltool"

src_prepare() {
	# Fix schemas path #
	sed -i "s:/usr/share:share:" setup.py || die

	distutils-r1_src_prepare
}

src_install() {
	distutils-r1_src_install

	insinto /usr/share/locale
	doins -r "${S}"/build/mo/*

	domenu "${S}"/build/share/applications/indicator-privacy.desktop
	dosym -r /usr/share/applications/"${PN}".desktop \
		/etc/xdg/autostart/"${PN}".desktop
}
