# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{8..10} )

URELEASE="impish"
inherit gnome2-utils cmake-utils eutils python-r1 ubuntu-versionator xdg-utils xdummy

UVER_PREFIX="+${UVER_RELEASE}.${PVR_MICRO}"

DESCRIPTION="Compiz Fusion OpenGL window and compositing manager patched for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/compiz"
SRC_URI="${UURL}/${MY_P}${UVER_PREFIX}-${UVER}.tar.xz"

LICENSE="GPL-2 LGPL-2.1 MIT"
SLOT="0/${PV}"
KEYWORDS="~amd64"
IUSE="+debug gles2 test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RESTRICT="mirror"

COMMONDEPEND="!!x11-wm/compiz
	!!x11-libs/compiz-bcop
	!!x11-libs/libcompizconfig
	!!x11-plugins/compiz-plugins-main
	dev-libs/boost:=[${PYTHON_USEDEP}]
	dev-libs/glib:2
	dev-cpp/glibmm
	dev-libs/libxml2[${PYTHON_USEDEP}]
	dev-libs/libxslt
	dev-libs/protobuf
	dev-python/cython[${PYTHON_USEDEP}]
	dev-python/python-distutils-extra[${PYTHON_USEDEP}]
	>=gnome-base/gsettings-desktop-schemas-3.8
	>=gnome-base/librsvg-2.14.0:2
	media-libs/glew:=
	media-libs/libpng:0=
	media-libs/mesa[gallium,llvm]
	x11-base/xorg-server[dmx]
	>=x11-libs/cairo-1.0
	x11-libs/gtk+:3
	x11-libs/libnotify
	x11-libs/pango
	x11-libs/libwnck:1
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXinerama
	x11-libs/libICE
	x11-libs/libSM
	>=x11-libs/startup-notification-0.7
	>=x11-wm/metacity-3.12
	!gles2? ( media-libs/glewmx )
	${PYTHON_DEPS}"

DEPEND="${COMMONDEPEND}
	dev-python/cython[${PYTHON_USEDEP}]
	sys-devel/gettext
	virtual/pkgconfig
	x11-base/xorg-proto
	test? ( dev-cpp/gtest
		>=dev-cpp/gtest-1.8.1
		sys-apps/xorg-gtest )"

RDEPEND="${COMMONDEPEND}
	dev-libs/protobuf:=
	unity-base/unity-language-pack
	x11-apps/mesa-progs
	x11-apps/xvinfo"

S="${WORKDIR}/${PN}"
MAKEOPTS="${MAKEOPTS} -j1"

src_prepare() {
	ubuntu-versionator_src_prepare

	# Gentoo's www-client/chromium Window Class ID is "Chromium-browser-chromium" for CCSMs Composite plugin "Undirect" list #
	#	www-client/google-chrome Window Class ID is "Google-chrome"
	#	media-tv/kodi Window Class ID is "Kodi"
	#  Fixes desktop freeze when returning from fullscreen video when using proprietary gfx drivers #
	sed -e 's:!(class=chromium-browser):!(class=chromium-browser) \&amp; !(class=Chromium-browser-chromium) \&amp; !(class=Google-chrome) \&amp; !(class=Kodi):g' \
		-i plugins/composite/composite.xml.in

	# Don't let compiz install /etc/compizconfig/config, violates sandbox and we install it from "${WORKDIR}/debian/compizconfig" anyway #
	sed '/add_subdirectory (config)/d' \
		-i compizconfig/libcompizconfig/CMakeLists.txt || die

	# Fix libdir #
	sed "s:/lib/:/$(get_libdir)/:g" \
		-i compizconfig/compizconfig-python/CMakeLists.txt || die

	# Unset CMAKE_BUILD_TYPE env variable so that cmake-utils.eclass doesn't try to "append-cppflags -DNDEBUG" #
	#	resulting in compiz window placement not working #
	export CMAKE_BUILD_TYPE=none

	# Gentoo 'cython3' binary is called 'cython' #
	sed -e 's:cython3:cython:g' \
		-i compizconfig/compizconfig-python/CMakeLists.txt || die

	# Need to do a 'python_foreach_impl' run from python-r1 eclass to workaround corrupt generated python shebang for /usr/bin/ccsm #
	#  Due to the way CMake invokes distutils setup.py, shebang will be inherited from the sandbox leading to runtime failure #
	python_copy_sources
	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_GLES=$(usex gles2 ON OFF)
		-DCMAKE_INSTALL_PREFIX="/usr"
		-DCOMPIZ_BUILD_TESTING=$(usex test ON OFF)
		-DCOMPIZ_BUILD_WITH_RPATH=FALSE
		-DCOMPIZ_DEFAULT_PLUGINS="ccp"
		-DCOMPIZ_DISABLE_GS_SCHEMAS_INSTALL=OFF
		-DCOMPIZ_PACKAGING_ENABLED=TRUE
		-DCOMPIZ_WERROR=OFF
	)
	configuration() {
		cmake-utils_src_configure
	}
	python_foreach_impl run_in_build_dir configuration
}

src_test() {
	# Current test results: #
	# 99% tests passed, 1 tests failed out of 1362 #
	# The following tests FAILED: #
	#       15 - GWDMockSettingsTest.TestMock (Failed) #

	local XDUMMY_COMMAND="cmake-utils_src_test"
	xdummymake
}

src_compile() {
	compilation() {
		cmake-utils_src_compile VERBOSE=1
	}
	python_foreach_impl run_in_build_dir compilation
}

src_install() {
	installation() {
		pushd ${CMAKE_BUILD_DIR}
			addpredict /usr/share/glib-2.0/schemas/
			emake DESTDIR="${ED}" install

			# Window manager desktop file for GNOME #
			insinto /usr/share/gnome/wm-properties/
			doins gtk/gnome/compiz.desktop

			# Keybinding files #
			insinto /usr/share/gnome-control-center/keybindings
			doins gtk/gnome/*.xml
		popd &> /dev/null
	}
	python_foreach_impl run_in_build_dir installation
	python_foreach_impl python_optimize

	pushd ${CMAKE_USE_DIR}
		CMAKE_DIR=$(cmake --system-information | grep '^CMAKE_ROOT' | awk -F\" '{print $2}')
		insinto "${CMAKE_DIR}/Modules/"
		doins cmake/FindCompiz.cmake
		doins cmake/FindOpenGLES2.cmake
		doins compizconfig/libcompizconfig/cmake/FindCompizConfig.cmake

		# Docs #
		dodoc AUTHORS NEWS README
		doman debian/{ccsm,compiz,gtk-window-decorator}.1

		insinto /usr/$(get_libdir)/compiz/migration/
		doins postinst/convert-files/*.convert

		# Default GSettings settings #
		insinto /usr/share/glib-2.0/schemas
		newins debian/compiz-gnome.gsettings-override 10_compiz-ubuntu.gschema.override
	popd &> /dev/null
}

pkg_preinst() { gnome2_schemas_savelist; }

pkg_postinst() {
	gnome2_schemas_update
	xdg_icon_cache_update
	ubuntu-versionator_pkg_postinst
}

pkg_postrm() {
	gnome2_schemas_update
	xdg_icon_cache_update
}
