# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{8..10} )

UVER="+21.10.20210501"
UREV="0ubuntu1"

inherit gnome2 cmake-utils python-single-r1 ubuntu-versionator

DESCRIPTION="Compiz Fusion OpenGL window and compositing manager patched for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/compiz"
SRC_URI="${UURL}-${UREV}.tar.xz"

LICENSE="GPL-2 LGPL-2.1 MIT"
SLOT="0/${PV}"
KEYWORDS="~amd64"
IUSE="gles2"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RESTRICT="${RESTRICT} test"

DEPEND="
	dev-cpp/glibmm
	dev-libs/glib:2
	dev-libs/libxslt
	dev-libs/protobuf
	>=gnome-base/gsettings-desktop-schemas-3.8
	>=gnome-base/librsvg-2.14.0:2
	media-libs/glew:=
	media-libs/libpng:0=
	media-libs/mesa[gallium,llvm]
	x11-base/xorg-server
	>=x11-libs/cairo-1.0
	x11-libs/gtk+:3
	x11-libs/libICE
	x11-libs/libnotify
	x11-libs/libSM
	x11-libs/libwnck:1
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXinerama
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/pango
	>=x11-libs/startup-notification-0.7
	>=x11-wm/metacity-3.22
	!gles2? (
		media-libs/glewmx
	)
	$(python_gen_cond_dep '
		dev-libs/boost:=[${PYTHON_USEDEP}]
		dev-libs/libxml2[${PYTHON_USEDEP}]
		dev-python/cython[${PYTHON_USEDEP}]
		dev-python/python-distutils-extra[${PYTHON_USEDEP}]
	')
	${PYTHON_DEPS}
"
BDEPEND="
	sys-devel/gettext
	virtual/pkgconfig
	x11-base/xorg-proto
"
RDEPEND="${DEPEND}
	dev-libs/protobuf:=
	unity-base/unity-language-pack
	x11-apps/mesa-progs
	x11-apps/xvinfo
"
PDEPEND="
	unity-base/unity[gles2=]
"

S="${WORKDIR}/${PN}"
MAKEOPTS="${MAKEOPTS} -j1"

src_prepare() {
	# Fix desktop freeze for Chromium, Chrome and Kodi when returning from fullscreen video when using proprietary gfx drivers #
	#  Related to Composite plugin - Unredirect Match, see https://askubuntu.com/questions/577459
	sed -i \
		-e 's:!(class=chromium-browser):!(class=chromium-browser) \&amp; !(class=Chromium-browser-chromium) \&amp; !(class=Google-chrome) \&amp; !(class=Kodi):' \
		plugins/composite/composite.xml.in || die

	# Disable recompiling GSettings schemas inside sandbox #
	sed -i \
		-e "/# Recompile GSettings Schemas/,+6 d" \
		cmake/CompizGSettings.cmake || die

	# Disable updating icon cache inside sandbox #
	sed -i \
		-e "/# Update icon cache/,+11 d" \
		compizconfig/ccsm/setup.py || die

	# Fix SyntaxWarning: "is" with a literal #
	sed -i \
		-e "s/is 0/== 0/" \
		compizconfig/compizconfig-python/setup.py || die

	# Fix 'implicitly converting 'FORCE' to 'STRING' type' warning #
	sed -i \
		-e "s/FORCE/STRING/" \
		compizconfig/cmake/exec_setup_py_with_destdir.cmake \
		cmake/copy_file_install_user_env.cmake || die

	python_fix_shebang compizconfig/ccsm

	ubuntu-versionator_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_GLES=$(usex gles2 ON OFF)
		-DBUILD_XORG_GTEST=OFF
		-DCMAKE_INSTALL_LOCALSTATEDIR="${EPREFIX}/var"
		-DCMAKE_INSTALL_LIBDIR="$(get_libdir)"
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr"
		-DCMAKE_INSTALL_SYSCONFDIR="${EPREFIX}/etc"
		-DCOMPIZ_BUILD_TESTING=OFF
		-DCOMPIZ_BUILD_WITH_RPATH=OFF
		-DCOMPIZ_DISABLE_GS_SCHEMAS_INSTALL=OFF
		-DCOMPIZ_PACKAGING_ENABLED=ON
		-DCOMPIZ_WERROR=OFF
		-Wno-dev
	)
	CMAKE_BUILD_TYPE="RelWithDebInfo" cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	python_optimize

	local CMAKE_DIR=$(cmake --system-information | grep "^CMAKE_ROOT " | sed -e 's/.*"\(.*\)"/\1/')
	insinto "${CMAKE_DIR}"/Modules
	doins cmake/FindCompiz.cmake
	doins cmake/FindOpenGLES2.cmake
	doins compizconfig/libcompizconfig/cmake/FindCompizConfig.cmake

	insinto /usr/share/glib-2.0/schemas
	newins debian/compiz-gnome.gsettings-override 10_compiz-ubuntu.gschema.override

	insinto /usr/lib/compiz/migration
	doins postinst/convert-files/*.convert

	dosym ../../applications/compiz.desktop \
		/usr/share/mate/wm-properties/compiz.desktop

	doman debian/{ccsm,compiz,gtk-window-decorator}.1
}
