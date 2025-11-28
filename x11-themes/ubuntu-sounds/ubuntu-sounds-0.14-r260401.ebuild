# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=build1
UREV=

inherit ubuntu-versionator

DESCRIPTION="Default audio theme for the Unity"
HOMEPAGE="https://launchpad.net/ubuntu-sounds"
SRC_URI="${UURL}.tar.xz"

LICENSE="CC-BY-SA-2.0 GPL-2+"
KEYWORDS="~amd64"
SLOT="0"
RESTRICT="binchecks strip test"

src_install() {
	default

	insinto /usr/share/sounds
	doins -r ubuntu
}
