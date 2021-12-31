# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

UVER=""
UREV=""

inherit ubuntu-versionator

DESCRIPTION="Default audio theme for the Unity"
HOMEPAGE="https://launchpad.net/ubuntu-sounds"
SRC_URI="${UURL}.tar.xz"

LICENSE="CC-BY-NC-SA-2.0"
KEYWORDS="~amd64"
SLOT="0"
IUSE=""
RESTRICT="${RESTRICT} binchecks strip"

src_install() {
	insinto /usr/share/sounds
	doins -r ubuntu
}
