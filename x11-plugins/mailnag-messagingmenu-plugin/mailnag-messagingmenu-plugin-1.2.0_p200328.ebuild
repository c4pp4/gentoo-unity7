# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..14} )

COMMIT="69f8e5f123643d7fdae28b77afec458ed976b086"

inherit distutils-r1 xdg

DESCRIPTION="Plugin that integrates Mailnag in the MessagingMenu indicator"
HOMEPAGE="https://github.com/pulb/mailnag-messagingmenu-plugin"
SRC_URI="https://github.com/pulb/mailnag-messagingmenu-plugin/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="mirror test"

RDEPEND="unity-indicators/indicator-messages"
DEPEND="${PYTHON_DEPS}"
PDEPEND=">=net-mail/mailnag-2.0.0"

S="${WORKDIR}/${PN}-${COMMIT}"
