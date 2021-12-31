# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

UVER="+18.10.20180612"
UREV="0ubuntu4"

inherit gnome2 cmake-utils ubuntu-versionator vala

DESCRIPTION="System sound indicator used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/indicator-sound"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"

RDEPEND="sys-auth/polkit-pkla-compat
	unity-base/gsettings-ubuntu-touch-schemas"
DEPEND="${RDEPEND}
	sys-apps/accountsservice
	dev-libs/libappindicator
	dev-libs/libgee:0.8
	dev-libs/libdbusmenu:=
	dev-util/dbus-test-runner
	media-sound/pulseaudio
	unity-base/bamf:=
	unity-base/unity-api
	unity-indicators/ido:=
	>=x11-libs/libnotify-0.7.6
	test? ( >=dev-cpp/gtest-1.8.1
		dev-libs/libqtdbusmock
		dev-libs/libqtdbustest )

	$(vala_depend)"

S="${WORKDIR}"
MAKEOPTS="${MAKEOPTS} -j1"

src_prepare() {
	# Disable all language files as they can be incomplete #
	#  due to being provided by Ubuntu's language-pack packages #
	sed -i \
		-e "/add_subdirectory(po)/d" \
		CMakeLists.txt

	# Disable tests #
	use test || sed -i \
		-e "/enable_testing()/d" \
		-e "/add_subdirectory(tests)/d" \
		CMakeLists.txt

	ubuntu-versionator_src_prepare
}

src_configure() {
	mycmakeargs+=(-DCMAKE_INSTALL_LOCALSTATEDIR=/var
		-DVALA_COMPILER=${VALAC}
		-DVAPI_GEN=${VAPIGEN}
		-DCMAKE_INSTALL_FULL_DATADIR=/usr/share)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	find "${ED}" -name "*.pkla" -exec chown root:polkitd {} \;
}
