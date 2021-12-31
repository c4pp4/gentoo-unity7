# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

UVER="+17.10.20170829.1"
UREV="0ubuntu7"

inherit gnome2 cmake-utils ubuntu-versionator

DESCRIPTION="Indicator showing power state used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/indicator-power"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+powerman test"

RDEPEND="powerman? ( gnome-extra/gnome-power-manager )"
DEPEND="${RDEPEND}
	dev-libs/glib:2
	dev-libs/libappindicator
	dev-libs/libdbusmenu
	sys-power/upower
	unity-base/unity-settings-daemon
	test? ( >=dev-cpp/gtest-1.8.1 )"

S="${WORKDIR}"
MAKEOPTS="${MAKEOPTS} -j1"

src_prepare() {
	# Fix schema errors and sandbox violations #
	sed -i \
		-e 's:SEND_ERROR:WARNING:g' \
		-e '/Compiling GSettings schemas/,+1 d' \
		cmake/UseGSettings.cmake

	# Deactivate gnome-power-statistics launcher
	use powerman \
		|| eapply "${FILESDIR}/disable-powerman.diff"

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
	local mycmakeargs=(
		-DCMAKE_INSTALL_FULL_LOCALEDIR=/usr/share/locale
	)

	cmake-utils_src_configure
}
