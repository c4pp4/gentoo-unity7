# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=+21.04.20210304
UREV=0ubuntu3

inherit gnome2 cmake ubuntu-versionator

DESCRIPTION="Date and Time Indicator used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/indicator-datetime"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="coverage +eds test"
REQUIRED_USE="coverage? ( test )"
RESTRICT="!test? ( test )"

COMMON_DEPEND="
	>=dev-libs/glib-2.43.2:2
	>=dev-libs/libical-3.0.0:=
	>=media-libs/gstreamer-1.0.0:1.0
	>=net-libs/libaccounts-glib-1.0:=
	sys-apps/systemd
	>=sys-apps/util-linux-2.16
	>=sys-devel/gcc-11
	>=sys-libs/glibc-2.14
	>=unity-base/gsettings-ubuntu-touch-schemas-0.0.7
	>=unity-indicators/indicator-messages-12.10.6
	>=x11-libs/libnotify-0.7.6
	x11-themes/ubuntu-touch-sounds

	eds? ( >=gnome-extra/evolution-data-server-3.17:= )
"
RDEPEND="${COMMON_DEPEND}
	dev-libs/libindicator:3
	gnome-base/dconf
"
DEPEND="${COMMON_DEPEND}
	dev-libs/properties-cpp
	>=dev-build/cmake-extras-1.1
	gnome-base/gvfs
	unity-base/unity-language-pack
	sys-apps/dbus

	test? (
		dev-cpp/gtest
		dev-python/python-dbusmock
		dev-util/dbus-test-runner

		coverage? (
			dev-util/gcovr
			dev-util/lcov
		)
	)
"
BDEPEND="dev-util/intltool"

S="${S}${UVER}"

MAKEOPTS="${MAKEOPTS} -j1"

PATCHES=( "${FILESDIR}"/optional-eds_19.10.patch )

src_prepare() {
	if use test; then
		sed -i "s/return/exit/" tests/run-eds-ics-test.sh || die

		use eds || sed -i \
			-e "/^add_eds_ics_test_by_name/d" \
			tests/CMakeLists.txt || die
	else
		# Make test optional #
		sed -i \
			-e "/enable_testing()/d" \
			-e "/add_subdirectory(tests)/d" \
			CMakeLists.txt || die
	fi

	# Fix schema errors and sandbox violations #
	sed -i \
		-e 's:SEND_ERROR:WARNING:g' \
		-e '/Compiling GSettings schemas/,+1 d' \
		cmake/UseGSettings.cmake || die

	# Disable all language files as they can be incomplete #
	#  due to being provided by Ubuntu's language-pack packages #
	sed -i "/add_subdirectory(po)/d" CMakeLists.txt || die

	ubuntu-versionator_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_FULL_LOCALEDIR=/usr/share/locale
		-DWITH_EDS="$(usex eds)"
		-Wno-dev
	)
	cmake_src_configure
}
