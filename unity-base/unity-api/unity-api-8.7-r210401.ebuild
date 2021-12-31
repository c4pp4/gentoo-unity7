# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

UVER="+17.04.20170404"
UREV="0ubuntu5"

inherit cmake-utils ubuntu-versionator

DESCRIPTION="API for Unity shell integration"
HOMEPAGE="https://launchpad.net/unity-api"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"

DEPEND="dev-libs/boost:=
	dev-libs/glib:2
	dev-libs/libqtdbustest
	dev-qt/qtdeclarative
	test? ( dev-util/cppcheck )"

S="${WORKDIR}"
export QT_SELECT=5

src_prepare() {
	sed -e 's:set(LIB_INSTALL_PREFIX lib/${CMAKE_LIBRARY_ARCHITECTURE}):set(LIB_INSTALL_PREFIX ${CMAKE_INSTALL_LIBDIR}):g' \
	-i ${S}/CMakeLists.txt || die

	ubuntu-versionator_src_prepare
}
