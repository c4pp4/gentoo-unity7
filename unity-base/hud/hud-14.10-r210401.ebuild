# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{8..10} )

UVER="+17.10.20170619"
UREV="0ubuntu4"

inherit cmake-utils distutils-r1 gnome2 ubuntu-versionator vala

DESCRIPTION="Backend for the Unity HUD"
HOMEPAGE="https://launchpad.net/hud"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc test"

DEPEND=">=dev-cpp/gtest-1.8.1
	dev-db/sqlite:3
	dev-libs/glib:2
	dev-libs/libcolumbus
	dev-libs/libdbusmenu:=
	dev-libs/libdbusmenu-qt
	dev-libs/libqtdbusmock
	dev-perl/XML-Parser
	dev-qt/qtcore:5
	dev-qt/qtdbus:5
	dev-qt/qtwidgets:5
	dev-qt/qtsql:5
	dev-qt/qttest:5
	gnome-base/dconf
	unity-base/bamf:=
	x11-libs/dee-qt
	x11-libs/gsettings-qt
	x11-libs/gtk+:3
	x11-libs/pango
	$(python_gen_cond_dep '
		dev-libs/dee[${PYTHON_MULTI_USEDEP}]
	')
	$(vala_depend)
	test? ( dev-util/dbus-test-runner )"

S="${S}${UVER}"

src_prepare() {
	# Fix "except ..., e: SyntaxError: invalid syntax" #
	sed -i \
		-e '/except /{s/,/ as/}' \
		tools/hudkeywords/hudkeywords/cli.py

	# Stop cmake doing the job of distutils #
	sed -i \
		-e '/add_subdirectory(hudkeywords)/d' \
		tools/CMakeLists.txt

	# Disable build of tests #
	sed -i \
		-e '/add_subdirectory(tests)/d' \
		CMakeLists.txt

	# Fix "attribute 'visible' invalid for element 'column'" #
	sed -i \
		-e 's/visible="0"//' \
		tools-vala/hud-gtk.ui

	ubuntu-versionator_src_prepare
}

src_configure() {
	mycmakeargs+=( -DENABLE_TESTS="$(usex test)"
			-DENABLE_DOCUMENTATION="$(usex doc)"
			-DENABLE_BAMF=ON
			-DVALA_COMPILER=$(type -P valac-${VALA_MIN_API_VERSION})
			-DVAPI_GEN=$(type -P vapigen-${VALA_MIN_API_VERSION})
			-DCMAKE_INSTALL_DATADIR=/usr/share )
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
	pushd tools/hudkeywords
		distutils-r1_src_compile
	popd
}

src_install() {
	cmake-utils_src_install
	pushd tools/hudkeywords
		distutils-r1_src_install
		python_fix_shebang "${ED}"
		python_optimize
	popd
}
