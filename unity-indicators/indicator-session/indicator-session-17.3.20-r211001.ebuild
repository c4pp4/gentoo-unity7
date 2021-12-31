# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

UVER="+21.10.20210613.1"
UREV="0ubuntu1"

inherit gnome2 cmake-utils ubuntu-versionator

DESCRIPTION="Indicator showing session management, status and user switching used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/indicator-session"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+help test"

RDEPEND="unity-base/unity-language-pack"
DEPEND="${RDEPEND}
	dev-libs/glib:2
	dev-libs/libappindicator:=
	dev-libs/libdbusmenu:=
	dev-util/cmake-extras
	dev-util/gdbus-codegen
	unity-base/unity-settings-daemon
	help? ( gnome-extra/yelp
		gnome-extra/gnome-user-docs
		unity-base/ubuntu-docs )
	test? ( >=dev-cpp/gtest-1.8.1 )"

S="${WORKDIR}"

src_prepare() {
	# Fix build attempting to violate sandbox #
	sed '/gtk-update-icon-cache/,+1 d' \
		-i data/icons/CMakeLists.txt || die

	# Remove dependency on whoopsie (Ubuntu's error submission tracker) #
	sed -e 's:libwhoopsie):):g' \
		-i CMakeLists.txt
	for each in $(grep -ri whoopsie | awk -F: '{print $1}'); do
		sed -e '/whoopsie/Id' -i "${each}"
	done

	if ! use help || has nodoc ${FEATURES}; then
		sed -n '/indicator.help/{s|^|//|};p' \
			-i src/service.c
	else
		sed -e 's:distro_name = g_strdup(value):distro_name = g_strdup(\"Unity\"):g' \
			-i src/service.c
		sed -e 's:yelp:yelp help\:ubuntu-help:g' \
			-i src/backend-dbus/actions.c
	fi

	# Disable all language files as they can be incomplete #
	#  due to being provided by Ubuntu's language-pack packages #
	sed -i \
		-e "/add_subdirectory (po)/d" \
		CMakeLists.txt

	# Disable tests #
	use test || sed -i \
		-e "/enable_testing ()/d" \
		-e "/add_subdirectory (tests)/d" \
		CMakeLists.txt

	ubuntu-versionator_src_prepare
}

src_install() {
	cmake-utils_src_install

	use help && domenu "${FILESDIR}/unity-yelp.desktop"
}
