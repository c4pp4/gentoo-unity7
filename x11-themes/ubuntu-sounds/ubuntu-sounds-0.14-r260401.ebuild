# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=build1
UREV=

inherit ubuntu-versionator

DESCRIPTION="Default sound theme for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/ubuntu-sounds"
SRC_URI="${UURL}.tar.xz"
S="${S}${UVER}"

LICENSE="CC-BY-SA-2.0 GPL-2+"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="binchecks strip test"

src_install() {
	default

	insinto /usr/share/sounds
	doins -r ubuntu

	dosym -r /usr/share/sounds/ubuntu/stereo/dialog-question.ogg \
		/usr/share/sounds/ubuntu/stereo/system-ready.ogg
}
