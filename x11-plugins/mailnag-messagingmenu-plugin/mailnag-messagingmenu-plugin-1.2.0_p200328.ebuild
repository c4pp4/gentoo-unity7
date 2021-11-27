# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{8..10} )

inherit distutils-r1 xdg

DESCRIPTION="Plugin that integrates Mailnag in the MessagingMenu indicator"
HOMEPAGE="https://github.com/pulb/mailnag-messagingmenu-plugin"
COMMIT="69f8e5f123643d7fdae28b77afec458ed976b086"
SRC_URI="https://github.com/pulb/mailnag-messagingmenu-plugin/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
RESTRICT="mirror"

BDEPEND="unity-indicators/indicator-messages"

RDEPEND="${BDEPEND}"

PDEPEND=">=net-mail/mailnag-2.0.0"

S="${WORKDIR}/${PN}-${COMMIT}"
