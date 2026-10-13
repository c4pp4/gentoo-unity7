# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=2

inherit cmake ubuntu-versionator

DESCRIPTION="QML bindings for GSettings"
HOMEPAGE="https://gitlab.com/ubports/development/core/gsettings-qt"
SRC_URI="${UURL}.orig.tar.bz2"
S="${WORKDIR}/${PN}-v${PV}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="test"
RESTRICT="!test? ( test )"

COMMON_DEPEND="
	>=dev-libs/glib-2.76.0:2
	>=dev-qt/qtbase-6.10.2:6
	>=dev-qt/qtdeclarative-6.6.0:6
"
RDEPEND="${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND}"
BDEPEND="
	>=dev-build/cmake-extras-1.8
	virtual/pkgconfig
"

src_prepare() {
	# Support new multilib layout #
	sed -i "s:/usr/lib/:/usr/$(get_libdir)/:" GSettings/CMakeLists.txt || die

	ubuntu-versionator_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING=$(usex test)
		-DENABLE_QT6=ON
		-Wno-dev
	)
	cmake_src_configure
}
