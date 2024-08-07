# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=+18.10.20180612
UREV=0ubuntu7

inherit gnome2 cmake ubuntu-versionator vala

DESCRIPTION="System sound indicator used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/indicator-sound"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="test"

COMMON_DEPEND="
	>=dev-libs/glib-2.43.92:2
	>=dev-libs/libgee-0.8.3:0.8
	|| (
		>=media-libs/libpulse-4.0[glib]
		media-video/pipewire
	)
	>=sys-apps/accountsservice-0.6.8
	>=unity-base/gsettings-ubuntu-touch-schemas-0.0.1
	>=x11-libs/libnotify-0.7.0
"
RDEPEND="${COMMON_DEPEND}
	dev-libs/libindicator:3
	gnome-base/dconf
	>=sys-libs/glibc-2.34
"
DEPEND="${COMMON_DEPEND}
	dev-libs/gobject-introspection
	dev-libs/libxml2:2
	>=dev-build/cmake-extras-0.10
	dev-qt/qtdeclarative:5
	gnome-base/gnome-common
	sys-apps/dbus
	sys-apps/systemd
	unity-base/unity-api

	$(vala_depend)
"
BDEPEND="dev-util/intltool"

MAKEOPTS="${MAKEOPTS} -j1"

src_unpack() {
	ubuntu-versionator_src_unpack
}

src_prepare() {
	# Make test optional #
	sed -i "s/TEST REQUIRED/TEST QUIET/" CMakeLists.txt || die

	# Fix error: unknown type name ‘VALA_EXTERN’ #
	sed -i "/add_definitions(/a -DVALA_EXTERN=extern" src/CMakeLists.txt || die

	# Disable all language files as they can be incomplete #
	#  due to being provided by Ubuntu's language-pack packages #
	sed -i "/add_subdirectory(po)/d" CMakeLists.txt || die

	ubuntu-versionator_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_LOCALSTATEDIR=/var
		-DVALA_COMPILER=${VALAC}
		-DVAPI_GEN=${VAPIGEN}
		-DCMAKE_INSTALL_FULL_DATADIR=/usr/share
		-Wno-dev
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install

	find "${ED}" -name "*.pkla" -exec chown root:polkitd {} \;
}
