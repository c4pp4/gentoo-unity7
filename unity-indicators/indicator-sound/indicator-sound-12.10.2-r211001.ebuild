# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

UVER=+18.10.20180612
UREV=0ubuntu4

inherit gnome2 cmake-utils ubuntu-versionator vala

DESCRIPTION="System sound indicator used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/indicator-sound"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="coverage test"
REQUIRED_USE="coverage? ( test )"
RESTRICT="${RESTRICT} !test? ( test )"

COMMON_DEPEND="
	>=dev-libs/glib-2.43.92:2
	>=dev-libs/libgee-0.8.3:0.8
	>=media-sound/pulseaudio-4.0[glib]
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
	>=dev-util/cmake-extras-0.10
	dev-qt/qtdeclarative
	gnome-base/gnome-common
	sys-apps/dbus
	sys-apps/systemd
	unity-base/unity-api

	test? (
		dev-cpp/gtest
		>=dev-libs/libqtdbusmock-0.3
		dev-libs/libqtdbustest
		dev-python/python-dbusmock
		>=dev-util/dbus-test-runner-15.04.0

		coverage? (
			dev-util/gcovr
			dev-util/lcov
		)
	)

	$(vala_depend)
"
BDEPEND="dev-util/intltool"

S="${WORKDIR}"

MAKEOPTS="${MAKEOPTS} -j1"

src_prepare() {
	# Disable tests #
	use test || sed -i \
		-e "s/TEST REQUIRED/TEST QUIET/" \
		-e "/enable_testing()/d" \
		-e "/add_subdirectory(tests)/d" \
		CMakeLists.txt || die

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
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	find "${ED}" -name "*.pkla" -exec chown root:polkitd {} \;
}
