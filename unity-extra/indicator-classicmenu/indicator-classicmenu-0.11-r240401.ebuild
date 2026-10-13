# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..15} )

UVER=
UREV=0ubuntu1
MY_PN="classicmenu-indicator"

inherit distutils-r1 xdg ubuntu-versionator

DESCRIPTION="Indicator showing the main menu from GNOME Classic"
HOMEPAGE="https://launchpad.net/classicmenu-indicator"
SRC_URI="${UURL/${PN}/${MY_PN}}.orig.tar.gz"
S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="test"

COMMON_DEPEND="
	dev-libs/glib:2
	dev-libs/libappindicator:3
	gnome-base/gnome-menus:3[introspection]
	x11-libs/gtk+:3[introspection]

	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/dbus-python[${PYTHON_USEDEP}]
		dev-python/pygobject:3[${PYTHON_USEDEP}]
	')
"
RDEPEND="${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND}"
BDEPEND="
	$(python_gen_cond_dep '
		dev-python/python-distutils-extra[${PYTHON_USEDEP}]
	')
"

src_prepare() {
	# Remove python2 deprecated attribute #
	sed -i "/bind_textdomain_codeset/d" classicmenu_indicator/cmindicator.py || die

	# Fix data dir and cmdclass #
	sed -i \
		-e "s:/usr/share/man:share/man:" \
		-e "s:/usr/share/icons:share/icons:" \
		-e "/build_/{s/# //}" \
		-e 's/"build_icons" :  build_icons.build_icons//' \
		setup.py || die

	# Fix "command 'build_i18n' has no such option 'po-dir'" with newer setuptools #
	sed -i \
		-e "s/^po-dir/po_dir/" \
		-e "s/^merge-po/merge_po/" \
		setup.cfg || die

	ubuntu-versionator_src_prepare
}

src_install() {
	distutils-r1_src_install

	dosym -r /usr/share/applications/classicmenu-indicator.desktop \
		/etc/xdg/autostart/classicmenu-indicator.desktop
	dosym -r /usr/share/icons/hicolor/scalable/apps/classicmenu-indicator-dark.svg \
		/usr/share/icons/hicolor/scalable/apps/classicmenu-indicator.svg
}
