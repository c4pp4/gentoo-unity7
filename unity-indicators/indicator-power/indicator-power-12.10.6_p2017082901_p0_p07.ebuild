# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

URELEASE="impish"
inherit cmake-utils gnome2-utils ubuntu-versionator

UVER_PREFIX="+17.10.${PVR_MICRO}"

DESCRIPTION="Indicator showing power state used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/indicator-power"
SRC_URI="${UURL}/${MY_P}${UVER_PREFIX}.orig.tar.gz
	${UURL}/${MY_P}${UVER_PREFIX}-${UVER}.diff.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+powerman test"
RESTRICT="mirror"

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
	ubuntu-versionator_src_prepare
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

	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_FULL_LOCALEDIR=/usr/share/locale
	)

	cmake-utils_src_configure
}

pkg_preinst() { gnome2_schemas_savelist; }

pkg_postinst() {
	gnome2_schemas_update
	ubuntu-versionator_pkg_postinst
}

pkg_postrm() { gnome2_schemas_update; }
