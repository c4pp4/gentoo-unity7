# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=+17.10.20170829.1
UREV=0ubuntu9

inherit gnome2 cmake ubuntu-versionator

DESCRIPTION="Indicator showing power state used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/indicator-power"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="+powerman"
RESTRICT="test"

COMMON_DEPEND="
	>=dev-libs/glib-2.39.4:2
	unity-base/gsettings-ubuntu-touch-schemas
	>=x11-libs/libnotify-0.7.6
"
RDEPEND="${COMMON_DEPEND}
	dev-libs/libindicator:3
	gnome-base/dconf
	sys-power/upower:=

	powerman? ( gnome-extra/gnome-power-manager )
"
DEPEND="${COMMON_DEPEND}
	dev-libs/libgudev:=
"
BDEPEND="
	>=dev-build/cmake-extras-0.10
	dev-util/intltool
	virtual/pkgconfig
"

MAKEOPTS="${MAKEOPTS} -j1"

PATCHES=( "${FILESDIR}"/fix-gcc-14-build.patch )

src_unpack() {
	ubuntu-versionator_src_unpack
}

src_prepare() {
	# Fix build with CMake 4 #
	sed -i "/cmake_minimum_required/{s/2\.8\.9/3.10/}" CMakeLists.txt || die

	# Fix schema errors and sandbox violations #
	sed -i \
		-e 's:SEND_ERROR:WARNING:g' \
		-e '/Compiling GSettings schemas/,+1 d' \
		cmake/UseGSettings.cmake || die

	# Disable all language files as they can be incomplete #
	#  due to being provided by Ubuntu's language-pack packages #
	cmake_comment_add_subdirectory po

	ubuntu-versionator_src_prepare

	# Deactivate gnome-power-statistics launcher #
	if ! use powerman; then
		sed -i \
			-e 's|^\(\s*g_menu_item_set_attribute (item, "x-canonical-type", "s", "com.canonical.indicator.basic");\)|//\1|' \
			-e 's|^\(\s*{ "activate-statistics", on_statistics_activated, "s" }\)|//\1|' \
			src/service.c || die
		grep -Eq '^//[[:space:]]*g_menu_item_set_attribute \(item, "x-canonical-type"' src/service.c || die
		grep -Eq '^//[[:space:]]*\{ "activate-statistics", on_statistics_activated, "s" \}' src/service.c || die
	fi
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_FULL_LOCALEDIR=/usr/share/locale
		-DCMAKE_POLICY_VERSION_MINIMUM=3.10
		-Wno-dev
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install

	# Indicator service D-Bus activation (delegated to systemd if running) #
	insinto /usr/share/dbus-1/services
	doins "${FILESDIR}"/com.canonical.indicator.power.service
}
