# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{8..10} )

COMMIT="69f8e5f123643d7fdae28b77afec458ed976b086"

inherit distutils-r1 xdg

DESCRIPTION="Plugin that integrates Mailnag in the MessagingMenu indicator"
HOMEPAGE="https://github.com/pulb/mailnag-messagingmenu-plugin"
SRC_URI="https://github.com/pulb/mailnag-messagingmenu-plugin/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="mirror test"

DEPEND="${PYTHON_DEPS}"
RDEPEND="${DEPEND}
	unity-indicators/indicator-messages
"
PDEPEND=">=net-mail/mailnag-2.0.0"

S="${WORKDIR}/${PN}-${COMMIT}"
