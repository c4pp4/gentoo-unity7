# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

UVER="+bzr42+repack1"
UREV="11"

inherit cmake-utils ubuntu-versionator

DESCRIPTION="Library to facilitate testing DBus interactions in Qt applications"
HOMEPAGE="https://launchpad.net/libqtdbustest"
SRC_URI="${UURL}.orig.tar.xz
	${UURL}-${UREV}.debian.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"

S="${S}${UVER%+*}"

DEPEND="dev-cpp/gtest
	dev-qt/qtcore:5
	dev-qt/qtdbus:5
	dev-qt/qttest:5
	dev-util/cmake-extras"

src_prepare() {
	# Fix build with >dev-cpp/gtest-1.8 "no rule to make target libgtest.a"
	sed -i "/find_package/{s/GMock/GTest/}" tests/CMakeLists.txt

	ubuntu-versionator_src_prepare
}
