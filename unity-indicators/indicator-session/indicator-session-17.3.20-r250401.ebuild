# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=+21.10.20210613.1
UREV=0ubuntu4

inherit desktop gnome2 cmake ubuntu-versionator

DESCRIPTION="Indicator showing session management, status and user switching used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/indicator-session"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="+help"
RESTRICT="test"

COMMON_DEPEND="
	>=dev-libs/glib-2.43.2:2
	sys-apps/systemd[pam]
"
RDEPEND="${COMMON_DEPEND}
	dev-libs/libindicator:3
	gnome-base/dconf
	gnome-base/gnome-settings-daemon
	gnome-base/gsettings-desktop-schemas
	>=sys-libs/glibc-2.4

	help? (
		gnome-extra/yelp
		gnome-extra/gnome-user-docs
		unity-base/ubuntu-docs
	)
"
DEPEND="${COMMON_DEPEND}
	>=dev-build/cmake-extras-1.3
	sys-apps/dbus
	unity-base/unity-settings-daemon
"
BDEPEND="dev-util/intltool"

src_unpack() {
	ubuntu-versionator_src_unpack
}

src_prepare() {
	if use help || ! has nodoc ${FEATURES}; then
		sed -i \
			-e 's:distro_name = g_strdup(value):distro_name = g_strdup(\"Unity\"):g' \
			src/service.c || die
		sed -i \
			-e 's:yelp:yelp help\:ubuntu-help:g' \
			src/backend-dbus/actions.c || die
	else
		sed -i \
			-e '/indicator.help/{s|^|//|};p' \
			src/service.c || die
	fi

	# Fix build attempting to violate sandbox #
	sed -i '/gtk-update-icon-cache/,+1 d' data/icons/CMakeLists.txt || die

	# Remove dependency on whoopsie (Ubuntu's error submission tracker) #
	sed -i 's:libwhoopsie):):g' CMakeLists.txt || die
	sed -i '/whoopsie/d' src/service.c || die

	# Disable all language files as they can be incomplete #
	#  due to being provided by Ubuntu's language-pack packages #
	sed -i "/add_subdirectory (po)/d" CMakeLists.txt || die

	ubuntu-versionator_src_prepare
}

src_install() {
	cmake_src_install

	use help && ! has nodoc ${FEATURES} && domenu "${FILESDIR}/unity-yelp.desktop"
}
