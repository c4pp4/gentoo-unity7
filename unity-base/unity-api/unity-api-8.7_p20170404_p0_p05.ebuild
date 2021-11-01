# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

URELEASE="impish"
inherit cmake-utils ubuntu-versionator

UVER_PREFIX="+17.04.${PVR_MICRO}"

DESCRIPTION="API for Unity shell integration"
HOMEPAGE="https://launchpad.net/unity-api"
SRC_URI="${UURL}/${MY_P}${UVER_PREFIX}.orig.tar.gz
	${UURL}/${MY_P}${UVER_PREFIX}-${UVER}.diff.gz"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"
RESTRICT="mirror"

DEPEND="dev-libs/boost:=
	dev-libs/glib:2
	dev-libs/libqtdbustest
	dev-qt/qtdeclarative
	test? ( dev-util/cppcheck )"

S="${WORKDIR}"
export QT_SELECT=5

src_prepare() {
	ubuntu-versionator_src_prepare

	sed -e 's:set(LIB_INSTALL_PREFIX lib/${CMAKE_LIBRARY_ARCHITECTURE}):set(LIB_INSTALL_PREFIX ${CMAKE_INSTALL_LIBDIR}):g' \
	-i ${S}/CMakeLists.txt || die

	cmake-utils_src_prepare
}
