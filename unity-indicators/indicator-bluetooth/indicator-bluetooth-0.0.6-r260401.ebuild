# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
GNOME2_EAUTORECONF="yes"

UVER=+17.10.20170605
UREV=0ubuntu7

inherit gnome2 ubuntu-versionator vala

DESCRIPTION="System bluetooth indicator used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/indicator-bluetooth"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"
S="${WORKDIR}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="test"

RDEPEND="
	>=dev-libs/glib-2.37.3:2
	dev-libs/libindicator:3
	gnome-base/dconf
	>=net-wireless/bluez-5
	net-wireless/gnome-bluetooth:3
	unity-base/unity-control-center[bluetooth]
"
DEPEND="
	dev-libs/glib:2
	sys-apps/systemd
"
BDEPEND="
	gnome-base/gnome-common
	virtual/pkgconfig

	$(vala_depend)
"

src_prepare() {
	# Disable all language files as they can be incomplete #
	#  due to being provided by Ubuntu's language-pack packages #
	> po/LINGUAS || die

	ubuntu-versionator_src_prepare
}
