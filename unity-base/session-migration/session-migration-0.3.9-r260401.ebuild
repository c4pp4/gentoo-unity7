# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=build2
UREV=

inherit cmake systemd ubuntu-versionator

DESCRIPTION="Tool to migrate in user session settings used by the Unity desktop"
HOMEPAGE="https://launchpad.net/session-migration"
SRC_URI="${UURL}.tar.xz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="test"

DEPEND=">=dev-libs/glib-2.51.1:2"
RDEPEND="${DEPEND}
	>=sys-libs/glibc-2.4
"

S="${S}${UVER}"

src_prepare() {
	# Fix build with CMake 4 #
	sed -i "/cmake_minimum_required/{s/2\.8/3.10/}" CMakeLists.txt || die

	ubuntu-versionator_src_prepare
}

src_install() {
	cmake_src_install

	dosym -r $(systemd_get_userunitdir)/session-migration.service \
		$(systemd_get_userunitdir)/graphical-session-pre.target.wants/session-migration.service
}
