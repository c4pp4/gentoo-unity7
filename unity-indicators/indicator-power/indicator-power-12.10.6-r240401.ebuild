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
	>=x11-libs/libnotify-0.7.6
"
RDEPEND="${COMMON_DEPEND}
	dev-libs/libindicator:3
	gnome-base/dconf
	>=sys-libs/glibc-2.4
	sys-power/upower:=

	powerman? ( gnome-extra/gnome-power-manager )
"
DEPEND="${COMMON_DEPEND}
	dev-libs/libgudev:=
	>=dev-build/cmake-extras-0.10
	sys-apps/systemd
	unity-base/gsettings-ubuntu-touch-schemas
"
BDEPEND="dev-util/intltool"

MAKEOPTS="${MAKEOPTS} -j1"

PATCHES=( "${FILESDIR}"/fix-gcc-14-build.patch )

src_unpack() {
	ubuntu-versionator_src_unpack
}

src_prepare() {
	# Fix schema errors and sandbox violations #
	sed -i \
		-e 's:SEND_ERROR:WARNING:g' \
		-e '/Compiling GSettings schemas/,+1 d' \
		cmake/UseGSettings.cmake || die

	# Deactivate gnome-power-statistics launcher
	use powerman || eapply "${FILESDIR}/disable-powerman.diff"

	# Disable all language files as they can be incomplete #
	#  due to being provided by Ubuntu's language-pack packages #
	cmake_comment_add_subdirectory po

	ubuntu-versionator_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_FULL_LOCALEDIR=/usr/share/locale
		-Wno-dev
	)
	cmake_src_configure
}
