# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=+14.04.20140317
UREV=0ubuntu9

inherit cmake ubuntu-versionator

DESCRIPTION="Qt binding and QML plugin for Dee for the Unity7 user interface"
HOMEPAGE="https://wiki.ubuntu.com/Unity"
S="${S}${UVER}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="test"
RESTRICT="!test? ( test )"

COMMON_DEPEND="
	>=dev-libs/dee-1.2.7:0=
	>=dev-libs/glib-2.24.0:2
	dev-qt/qtbase:6[dbus]
	dev-qt/qtdeclarative:6
"
RDEPEND="${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND}"
BDEPEND="
	virtual/pkgconfig
	test? ( dev-util/dbus-test-runner )
"

PATCHES=( "${FILESDIR}"/Qt6-migration.patch )

src_prepare() {
	# Make test optional #
	use test || cmake_comment_add_subdirectory tests

	ubuntu-versionator_src_prepare
}
