# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..15} )

COMMIT="69f8e5f123643d7fdae28b77afec458ed976b086"

inherit distutils-r1 xdg

DESCRIPTION="Plugin that integrates Mailnag in the MessagingMenu indicator"
HOMEPAGE="https://github.com/pulb/mailnag-messagingmenu-plugin"
SRC_URI="https://github.com/pulb/mailnag-messagingmenu-plugin/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-${COMMIT}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="mirror test"

RDEPEND="
	unity-indicators/indicator-messages
	x11-libs/gtk+:3[introspection]

	$(python_gen_cond_dep '
		dev-python/dbus-python[${PYTHON_USEDEP}]
		dev-python/pygobject:3[${PYTHON_USEDEP}]
	')
"
PDEPEND=">=net-mail/mailnag-2.0.0[${PYTHON_SINGLE_USEDEP}]"

src_prepare() {
	# Run the action launcher via its shebang, python2 is gone #
	sed -i "s:python2 %PREFIX%:%PREFIX%:" mailnag-messagingmenu.desktop.in || die

	distutils-r1_src_prepare
}
