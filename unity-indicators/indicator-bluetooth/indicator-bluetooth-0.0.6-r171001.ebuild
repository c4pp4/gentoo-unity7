# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
GNOME2_EAUTORECONF="yes"

UVER="+17.10.20170605"
UREV="0ubuntu3"

inherit gnome2 ubuntu-versionator vala

DESCRIPTION="System bluetooth indicator used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/indicator-bluetooth"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND=">=net-wireless/bluez-5
	media-sound/pulseaudio[bluetooth]"
DEPEND="${RDEPEND}
	dev-libs/glib:2
	dev-libs/libappindicator:=
	dev-libs/libdbusmenu:=
	dev-libs/libindicator:3=
	gnome-base/dconf
	unity-base/unity-control-center
	unity-indicators/ido:=
	x11-libs/gtk+:3
	$(vala_depend)"

S="${WORKDIR}"

src_prepare() {
	# Disable all language files as they can be incomplete #
        #  due to being provided by Ubuntu's language-pack packages #
        > po/LINGUAS

	ubuntu-versionator_src_prepare
}
