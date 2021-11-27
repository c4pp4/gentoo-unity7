# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

UVER="+19.04.20190412"
UREV="0ubuntu2"

inherit autotools ubuntu-versionator vala virtualx

DESCRIPTION="Home scope that aggregates results from multiple scopes for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/unity-scope-home"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"

DEPEND="dev-libs/dee:=
	dev-libs/glib:2
	dev-libs/json-glib
	dev-libs/libgee
	dev-libs/libunity:=
	net-libs/libsoup
	net-libs/liboauth
	sys-apps/util-linux
	unity-base/unity
	$(vala_depend)"

S="${WORKDIR}"

src_prepare() {
	eapply "${FILESDIR}/0002-productsearch.ubuntu.com-only-accepts-locale-string.patch"
	ubuntu-versionator_src_prepare
	eautoreconf
}

src_configure() {
	use test || local myconf="--enable-headless-tests=no"
	econf "${myconf}"
}
