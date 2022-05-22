# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

UVER=
UREV=1

inherit ubuntu-versionator

DESCRIPTION="Default backgrounds in Ubuntu Unity"
HOMEPAGE="https://gitlab.com/ubuntu-unity"
SRC_URI="https://launchpad.net/~ubuntu-unity-devs/+archive/ubuntu/stable/+files/${PN}_${PV}${UVER}-${UREV}.tar.gz"

LICENSE="CC-BY-NC-SA-4.0"
KEYWORDS="~amd64"
SLOT="0"
RESTRICT="${RESTRICT} binchecks strip test"

src_install() {
	default

	insinto /usr/share/backgrounds
	doins -r ubuntu-unity

	insinto /usr/share/gnome-background-properties
	doins ubuntu-unity.xml
}
