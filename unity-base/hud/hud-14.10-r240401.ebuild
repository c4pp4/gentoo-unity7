# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_OPTIONAL=1
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..14} )

UVER=+17.10.20170619
UREV=0ubuntu6

inherit distutils-r1 cmake gnome2 ubuntu-versionator vala

DESCRIPTION="Backend for the Unity HUD"
HOMEPAGE="https://launchpad.net/hud"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="doc test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RESTRICT="!test? ( test )"

COMMON_DEPEND="
	>=dev-libs/dee-0.5.2:0=[${PYTHON_SINGLE_USEDEP}]
	>=dev-libs/glib-2.37.3:2
	>=dev-libs/libcolumbus-1.1.0:0=[${PYTHON_SINGLE_USEDEP}]
	>=dev-libs/libdbusmenu-qt-0.9.3_pre20160218
	>=dev-qt/qtcore-5.15.1:5
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
	>=dev-libs/libdbusmenu-0.5.90[gtk3,test?]
	>=dev-build/cmake-extras-0.10
	gnome-base/gnome-common
	sys-apps/systemd

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

	$(python_gen_cond_dep '
		>=dev-python/setuptools-65.7.0[${PYTHON_USEDEP}]
	')
	${PYTHON_DEPS}
"

S="${S}${UVER}"

wrap_distutils() {
	pushd tools/hudkeywords >/dev/null || die
		distutils-r1_${1}
	popd >/dev/null || die
}

src_prepare() {
	# As of focal 14.10+17.10.20170619-0ubuntu3, disable #
	# gtkdoc-mktmpl as it was removed from gtk-doc 1.26. #
	if use doc; then
		sed -i \
			-e '/subdirectory(libhud/d' \
			docs/CMakeLists.txt || die
	fi

	# Don't try to find test deps #
	if ! use test; then
		sed -i \
			-e '/QTDBUSTEST/d' \
			-e '/QTDBUSMOCK/d' \
			CMakeLists.txt || die
	fi

	# Stop cmake doing the job of distutils #
	sed -i \
		-e '/add_subdirectory(hudkeywords)/d' \
		tools/CMakeLists.txt || die

	# Fix "except ..., e: SyntaxError: invalid syntax" #
	sed -i \
		-e '/except /{s/,/ as/}' \
		tools/hudkeywords/hudkeywords/cli.py || die

	# Remove invalid attribute #
	sed -i 's/ visible="0"//' tools-vala/hud-gtk.ui || die

	python_fix_shebang tools/hudkeywords
	wrap_distutils ${FUNCNAME}

	ubuntu-versionator_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=OFF
		-DCMAKE_INSTALL_DATADIR=/usr/share
		-DENABLE_BAMF=ON
		-DENABLE_DOCUMENTATION=$(usex doc ON OFF)
		-DENABLE_TESTS=$(usex test ON OFF)
		-DVALA_COMPILER=${VALAC}
		-DVAPI_GEN=${VAPIGEN}
		-Wno-dev
	)
	cmake_src_configure

	wrap_distutils ${FUNCNAME}
}

src_compile() {
	cmake_src_compile
	wrap_distutils ${FUNCNAME}
}

src_install() {
	cmake_src_install

	wrap_distutils ${FUNCNAME}
	python_optimize
}
