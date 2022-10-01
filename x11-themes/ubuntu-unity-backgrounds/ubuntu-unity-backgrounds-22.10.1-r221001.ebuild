# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=0ubuntu1

inherit ubuntu-versionator

DESCRIPTION="Default backgrounds in Ubuntu Unity"
HOMEPAGE="https://gitlab.com/ubuntu-unity"
SRC_URI="${UURL}.orig.tar.xz"

LICENSE="CC-BY-NC-SA-4.0"
KEYWORDS="~amd64"
SLOT="0"
RESTRICT="binchecks strip test"

src_install() {
	default

	insinto /usr/share/backgrounds
	doins -r ubuntu-unity

	insinto /usr/share/gnome-background-properties
	doins ubuntu-unity.xml
}
