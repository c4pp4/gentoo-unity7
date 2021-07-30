# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

URELEASE="hirsute"
inherit cmake-utils gnome2-utils ubuntu-versionator xdg-utils

UVER_PREFIX="+${UVER_RELEASE}.${PVR_MICRO}"

DESCRIPTION="Indicator showing session management, status and user switching used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/indicator-session"
SRC_URI="${UURL}/${MY_P}${UVER_PREFIX}.orig.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+help test"
RESTRICT="mirror"

RDEPEND="unity-base/unity-language-pack"
DEPEND="${RDEPEND}
	dev-libs/glib:2
	dev-libs/libappindicator:=
	dev-libs/libdbusmenu:=
	help? ( gnome-extra/yelp
		gnome-extra/gnome-user-docs
		unity-base/ubuntu-docs )
	test? ( >=dev-cpp/gtest-1.8.1 )"

S="${WORKDIR}"

src_prepare() {
	ubuntu-versionator_src_prepare

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

	cmake-utils_src_prepare
}

src_install() {
	cmake-utils_src_install

	use help && domenu "${FILESDIR}/unity-yelp.desktop"
}

pkg_preinst() {
	gnome2_schemas_savelist
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_schemas_update
	gnome2_icon_cache_update
	xdg_desktop_database_update
	ubuntu-versionator_pkg_postinst
}

pkg_postrm() {
	gnome2_schemas_update
	gnome2_icon_cache_update
	xdg_desktop_database_update
}
