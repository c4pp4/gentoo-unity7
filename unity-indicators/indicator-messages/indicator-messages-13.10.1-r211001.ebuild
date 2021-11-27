# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
GNOME2_EAUTORECONF="yes"
GNOME2_LA_PUNT="yes"

UVER="+18.10.20180918"
UREV="0ubuntu3"

inherit gnome2 vala ubuntu-versionator

DESCRIPTION="Indicator that collects messages that need a response used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/indicator-messages"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="!net-im/indicator-messages
	dev-libs/libappindicator
	dev-libs/libdbusmenu
	dev-util/dbus-test-runner
	$(vala_depend)"

S="${WORKDIR}"
