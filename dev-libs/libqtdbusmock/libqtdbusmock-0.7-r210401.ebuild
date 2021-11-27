# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

UVER="+bzr49+repack1"
UREV="5"

inherit cmake-utils ubuntu-versionator

DESCRIPTION="Qt Bindings for python-dbusmock"
HOMEPAGE="https://launchpad.net/libqtdbusmock"
SRC_URI="${UURL}.orig.tar.xz
	${UURL}-${UREV}.debian.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"

# Networkmanager >1.20 removes NetworkManager.pc and libnm-{util,glib,glib-vpn}.pc #
DEPEND=">=dev-cpp/gtest-1.8.1
	dev-libs/libqtdbustest
	net-misc/networkmanager"

S="${S}${UVER%+*}"

src_prepare() {
	# Disable build of tests #
	use test || sed -i '/add_subdirectory(tests)/d' CMakeLists.txt

	ubuntu-versionator_src_prepare
}
