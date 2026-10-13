# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=build2
UREV=

inherit ubuntu-versionator

DESCRIPTION="Notification and ringtone sounds from Ubuntu Touch"
HOMEPAGE="https://launchpad.net/ubuntu/+source/ubuntu-touch-sounds"
SRC_URI="${UURL}.tar.gz"
S="${S}${UVER}"

LICENSE="CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="binchecks strip test"

src_install() {
	default

	insinto /usr/share/sounds/ubuntu
	doins -r notifications ringtones
}
