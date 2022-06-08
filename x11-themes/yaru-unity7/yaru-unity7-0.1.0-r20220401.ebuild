# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=

inherit meson xdg ubuntu-versionator

DESCRIPTION="Yaru theme for Unity7"
HOMEPAGE="https://gitlab.com/ubuntu-unity/yaru-unity7"
SRC_URI="https://launchpad.net/~ubuntu-unity-devs/+archive/ubuntu/stable/+files/${PN}_${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="extra"
RESTRICT="binchecks strip test"

RDEPEND="
	dev-libs/glib:2
	x11-libs/gtk+:2
	x11-themes/gtk-engines-adwaita
	x11-themes/gtk-engines-murrine

	extra? ( x11-themes/yaru-theme )
"
BDEPEND="
	dev-libs/glib:2
	dev-lang/sassc
"
