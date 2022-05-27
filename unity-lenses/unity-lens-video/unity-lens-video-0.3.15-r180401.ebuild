# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
UBUNTU_EAUTORECONF="yes"

UVER=+16.04.20160212.1
UREV=0ubuntu3

inherit vala ubuntu-versionator

DESCRIPTION="Video lens for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/unity-lens-video"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="${RESTRICT} test"

COMMON_DEPEND="
	>=dev-libs/dee-1.0.7:0=
	>=dev-libs/glib-2.37.3:2
	>=dev-libs/json-glib-0.12.0
	>=dev-libs/libgee-0.8.3:0.8
	>=dev-libs/libunity-7.0.9:0=
	>=dev-libs/libzeitgeist-0.3.14
	>=net-libs/libsoup-2.27.4:2.4
"
RDEPEND="${COMMON_DEPEND}
	>=sys-libs/glibc-2.4
"
DEPEND="${COMMON_DEPEND}
	gnome-base/gnome-common

	$(vala_depend)
"

S="${S}${UVER}"
