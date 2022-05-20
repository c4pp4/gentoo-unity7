# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{8..10} )

UVER=+17.10.20170619
UREV=0ubuntu4

inherit distutils-r1 cmake-utils gnome2 ubuntu-versionator vala

DESCRIPTION="Backend for the Unity HUD"
HOMEPAGE="https://launchpad.net/hud"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc test"
RESTRICT="${RESTRICT} !test? ( test )"

COMMON_DEPEND="
	>=dev-libs/dee-0.5.2:=[${PYTHON_SINGLE_USEDEP}]
	>=dev-libs/glib-2.37.3:2
	>=dev-libs/libcolumbus-1.1.0:=[${PYTHON_SINGLE_USEDEP}]
	>=dev-libs/libdbusmenu-qt-0.9.3_pre20160218
	>=dev-qt/qtcore-5.15.1:5[systemd]
	>=dev-qt/qtdbus-5.0.2:5
	>=dev-qt/qtgui-5.0.2:5
	>=dev-qt/qtsql-5.0.2:5[sqlite]
	dev-qt/qttest:5
	>=dev-qt/qtwidgets-5.0.2:5
	>=x11-libs/dee-qt-3.3
	>=x11-libs/gsettings-qt-0.1
	>=x11-libs/gtk+-3.5.4:3[introspection]

	${PYTHON_DEPS}
"
RDEPEND="${COMMON_DEPEND}
	dev-db/sqlite:3
	gnome-base/dconf
	>=sys-devel/gcc-5.2
	>=sys-libs/glibc-2.14
	>=x11-libs/pango-1.14.0[introspection]

	$(python_gen_cond_dep '
		dev-python/lxml[${PYTHON_USEDEP}]
	')
"
DEPEND="${COMMON_DEPEND}
	>=dev-libs/libdbusmenu-0.5.90[gtk3,test]
	>=dev-util/cmake-extras-0.10
	gnome-base/gnome-common

	doc? (
		dev-libs/libxslt
		dev-util/gtk-doc
		media-gfx/mscgen
		media-libs/gd[fontconfig]
	)
	test? (
		>=dev-cpp/gtest-1.6.0
		>=dev-libs/libqtdbusmock-0.2[${PYTHON_SINGLE_USEDEP}]
		>=dev-libs/libqtdbustest-0.2
		x11-misc/xvfb-run
	)

	$(vala_depend)
"
BDEPEND="
	dev-util/intltool
	virtual/pkgconfig
"

S="${S}${UVER}"

src_prepare() {
	# As of focal 14.10+17.10.20170619-0ubuntu3, disable #
	# gtkdoc-mktmpl as it was removed from gtk-doc 1.26. #
	use doc && ( sed -i \
		-e '/subdirectory(libhud/d' \
		docs/CMakeLists.txt || die )

	# Don't try to find test deps #
	use test || sed -i \
		-e '/QTDBUSTEST/d' \
		-e '/QTDBUSMOCK/d' \
		CMakeLists.txt || die

	# Stop cmake doing the job of distutils #
	sed -i \
		-e '/add_subdirectory(hudkeywords)/d' \
		tools/CMakeLists.txt || die

	# Fix "except ..., e: SyntaxError: invalid syntax" #
	sed -i \
		-e '/except /{s/,/ as/}' \
		tools/hudkeywords/hudkeywords/cli.py || die

	python_fix_shebang tools/hudkeywords

	ubuntu-versionator_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=OFF
		-DCMAKE_INSTALL_DATADIR=/usr/share
		-DENABLE_BAMF=ON
		-DENABLE_DOCUMENTATION=$(usex doc ON OFF)
		-DENABLE_TESTS=$(usex test ON OFF)
		-DVALA_COMPILER=$(type -P valac-${VALA_MIN_API_VERSION})
		-DVAPI_GEN=$(type -P vapigen-${VALA_MIN_API_VERSION})
		-Wno-dev
	)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile

	pushd tools/hudkeywords >/dev/null || die
		distutils-r1_src_compile
	popd >/dev/null || die
}

src_install() {
	cmake-utils_src_install

	pushd tools/hudkeywords >/dev/null || die
		distutils-r1_src_install
		python_optimize
	popd >/dev/null || die
}
