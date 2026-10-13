# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
UBUNTU_EAUTORECONF="yes"

UVER=+19.04.20190412
UREV=0ubuntu8

inherit vala ubuntu-versionator

DESCRIPTION="Home scope that aggregates results from multiple scopes for Unity7"
HOMEPAGE="https://launchpad.net/unity-scope-home"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.debian.tar.xz"
S="${WORKDIR}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
# Tests fail silently: the fake server needs the removed Python cgi module #
RESTRICT="test"

COMMON_DEPEND="
	>=dev-libs/dee-1.2.7:0=
	>=dev-libs/glib-2.43.92:2
	>=dev-libs/json-glib-0.13.2
	>=dev-libs/libgee-0.8.3:0.8
	>=dev-libs/libunity-7.1.4:0=
"
RDEPEND="${COMMON_DEPEND}
	sys-apps/lsb-release
"
DEPEND="${COMMON_DEPEND}
	>=sys-apps/util-linux-2.16
"
BDEPEND="
	dev-util/intltool
	sys-devel/gettext
	virtual/pkgconfig
	$(vala_depend)
"

PATCHES=( "${FILESDIR}"/Remove-Software-center-and-1kB-filter-option-and-fix-100kB.patch )
