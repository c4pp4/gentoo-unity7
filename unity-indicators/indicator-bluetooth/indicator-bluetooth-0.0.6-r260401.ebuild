# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
GNOME2_EAUTORECONF="yes"

UVER=+17.10.20170605
UREV=0ubuntu6

inherit gnome2 ubuntu-versionator vala

DESCRIPTION="System bluetooth indicator used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/indicator-bluetooth"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="test"

RDEPEND="
	>=dev-libs/glib-2.37.3:2
	dev-libs/libindicator:3
	gnome-base/dconf
	>=net-wireless/bluez-5
	net-wireless/gnome-bluetooth:3
	>=sys-libs/glibc-2.4
	unity-base/unity-control-center
"
DEPEND="
	dev-libs/glib:2
	gnome-base/gnome-common
	sys-apps/systemd

	$(vala_depend)
"

S="${WORKDIR}"

src_prepare() {
	# Disable all language files as they can be incomplete #
        #  due to being provided by Ubuntu's language-pack packages #
        > po/LINGUAS

	ubuntu-versionator_src_prepare
}
