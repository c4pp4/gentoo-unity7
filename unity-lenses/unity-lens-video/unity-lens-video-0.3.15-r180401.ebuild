# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
UBUNTU_EAUTORECONF="yes"

UVER="+16.04.20160212.1"
UREV="0ubuntu3"

inherit vala ubuntu-versionator

DESCRIPTION="Video lens for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/unity-lens-video"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="!unity-lenses/unity-scope-video-remote
	dev-libs/dee:=
	dev-libs/libunity:="
DEPEND="dev-libs/dee
	dev-libs/glib:2
	dev-libs/json-glib
	dev-libs/libgee
	dev-libs/libunity
	dev-libs/libzeitgeist
	net-libs/libsoup
	unity-base/unity
	$(vala_depend)"

S="${S}${UVER}"
