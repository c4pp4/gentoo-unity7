# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=+14.04.20140317
UREV=0ubuntu9

inherit cmake ubuntu-versionator

DESCRIPTION="Qt binding and QML plugin for Dee for the Unity7 user interface"
HOMEPAGE="https://wiki.ubuntu.com/Unity"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="test"
RESTRICT="!test? ( test )"

COMMON_DEPEND="
	>=dev-libs/dee-1.0.0:0=
	dev-qt/qtbase:6
	dev-qt/qtdeclarative:6
"
RDEPEND="${COMMON_DEPEND}
	>=dev-libs/glib-2.24.0:2
	>=sys-devel/gcc-4.9
	>=sys-libs/glibc-2.14
"
DEPEND="${COMMON_DEPEND}
	test? ( dev-util/dbus-test-runner )
"

S="${S}${UVER}"

PATCHES=( "${FILESDIR}"/Qt6-migration.patch )

src_prepare() {
	# Make test optional #
	use test || cmake_comment_add_subdirectory tests

	ubuntu-versionator_src_prepare
}
