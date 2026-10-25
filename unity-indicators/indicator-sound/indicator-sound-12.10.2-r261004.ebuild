# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=+18.10.20180612
UREV=0ubuntu10

inherit gnome2 cmake ubuntu-versionator vala

DESCRIPTION="System sound indicator used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/indicator-sound"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="+rtkit"

COMMON_DEPEND="
	>=dev-libs/glib-2.43.92:2
	>=dev-libs/libgee-0.8.3:0.8
	dev-libs/libxml2:2=
	>=media-libs/libpulse-4.0[glib]
	>=sys-apps/accountsservice-0.6.8:=[introspection]
	>=x11-libs/libnotify-0.7.0
"
RDEPEND="${COMMON_DEPEND}
	acct-group/polkitd
	dev-libs/libindicator:3
	gnome-base/dconf
	>=unity-base/gsettings-ubuntu-touch-schemas-0.0.1

	rtkit? ( sys-auth/rtkit )
"
DEPEND="${COMMON_DEPEND}"
BDEPEND="
	acct-group/polkitd
	>=dev-build/cmake-extras-0.10
	virtual/pkgconfig
	$(vala_depend)
"

PATCHES=(
	"${FILESDIR}"/connect-to-playlists-proxy.patch
	"${FILESDIR}"/exit-without-finalizing-on-sigterm.patch
	"${FILESDIR}"/fix-notification-icon.patch
	"${FILESDIR}"/forget-uninstalled-players.patch
	"${FILESDIR}"/greeter-user-lookup-on-name-owner.patch
	"${FILESDIR}"/implement-greeter-player-controls.patch
	"${FILESDIR}"/quiet-missing-pulseaudio-dbus.patch
	"${FILESDIR}"/remove-playlist-item-only-if-present.patch
)

src_unpack() {
	ubuntu-versionator_src_unpack
}

src_prepare() {
	# Make test optional #
	sed -i "s/TEST REQUIRED/TEST QUIET/" CMakeLists.txt || die

	# Do not delay the logout for 90 s if the service hangs on termination #
	sed -i "/^Restart=/a TimeoutStopSec=10" data/indicator-sound.service.in || die
	grep -qx "TimeoutStopSec=10" data/indicator-sound.service.in || die

	# Disable all language files as they can be incomplete #
	#  due to being provided by Ubuntu's language-pack packages #
	cmake_comment_add_subdirectory po

	# Test helper library only, tests are disabled upstream #
	cmake_comment_add_subdirectory -f src gmenuharness

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

	fowners root:polkitd /var/lib/polkit-1/localauthority/10-vendor.d/50-com.canonical.indicator.sound.AccountsService.pkla

	# Indicator service D-Bus activation (delegated to systemd if running) #
	insinto /usr/share/dbus-1/services
	doins "${FILESDIR}"/com.canonical.indicator.sound.service
}
