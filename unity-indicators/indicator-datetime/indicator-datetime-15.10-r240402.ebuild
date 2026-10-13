# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{12..15} )

UVER=+21.04.20210304
UREV=0ubuntu6

inherit gnome2 cmake python-any-r1 ubuntu-versionator

DESCRIPTION="Date and Time Indicator used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/indicator-datetime"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"
S="${S}${UVER}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="+eds test"
RESTRICT="!test? ( test )"

COMMON_DEPEND="
	>=dev-libs/glib-2.43.2:2
	>=dev-libs/libical-3.0.0:=
	>=media-libs/gstreamer-1.0.0:1.0
	>=net-libs/libaccounts-glib-1.0:=
	sys-apps/systemd
	>=sys-apps/util-linux-2.16
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

	test? ( dev-cpp/gtest )
"
BDEPEND="
	>=dev-build/cmake-extras-1.1
	dev-util/intltool
	virtual/pkgconfig

	test? (
		dev-util/dbus-test-runner
		gnome-base/gvfs
		sys-apps/dbus

		${PYTHON_DEPS}
		$(python_gen_any_dep 'dev-python/python-dbusmock[${PYTHON_USEDEP}]')
	)
"

MAKEOPTS="${MAKEOPTS} -j1"

PATCHES=( "${FILESDIR}"/optional-eds_19.10.patch )

python_check_deps() {
	use test || return 0
	python_has_version "dev-python/python-dbusmock[${PYTHON_USEDEP}]"
}

src_prepare() {
	if use test; then
		eapply "${FILESDIR}"/fix-tests-libnotify-0.8.patch

		sed -i "s/return/exit/" tests/run-eds-ics-test.sh || die
	else
		cmake_comment_add_subdirectory tests
	fi

	# Fix build with CMake 4 #
	sed -i "/cmake_minimum_required/{s/2\.8\.9/3.10/}" CMakeLists.txt || die

	# Error: ‘uint32_t’ was not declared in this scope #
	sed -i '/#include <vector>/a #include <cstdint>' src/haptic.cpp || die

	# Fix schema errors and sandbox violations #
	sed -i \
		-e 's:SEND_ERROR:WARNING:g' \
		-e '/Compiling GSettings schemas/,+1 d' \
		cmake/UseGSettings.cmake || die

	# Disable all language files as they can be incomplete #
	#  due to being provided by Ubuntu's language-pack packages #
	cmake_comment_add_subdirectory po

	ubuntu-versionator_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_FULL_LOCALEDIR=/usr/share/locale
		-DCMAKE_POLICY_VERSION_MINIMUM=3.10
		-DWITH_EDS="$(usex eds)"
		-Wno-dev
	)
	cmake_src_configure
}
