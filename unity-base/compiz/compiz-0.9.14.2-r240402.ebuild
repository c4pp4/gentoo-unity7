# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{10..13} )

UVER=+22.10.20220822
UREV=0ubuntu12

inherit gnome2 cmake python-single-r1 ubuntu-versionator

DESCRIPTION="Compiz Fusion OpenGL window and compositing manager patched for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/compiz"
SRC_URI="${UURL}-${UREV}.tar.xz"

LICENSE="GPL-2 LGPL-2.1 MIT"
SLOT="0/$(usub)"
KEYWORDS="amd64"
IUSE="gles2 mate"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RESTRICT="test"

COMMON_DEPEND="
	>=dev-cpp/glibmm-2.64.2:2
	>=dev-libs/glib-2.39.4:2
	dev-libs/libxslt
	>=dev-libs/protobuf-3.12.4:=
	gnome-base/gsettings-desktop-schemas
	>=gnome-base/librsvg-2.14.4
	>=media-libs/libjpeg-turbo-1.1.90
	>=media-libs/libpng-1.6.2:0=
	virtual/glu
	>=x11-libs/cairo-1.14.0
	>=x11-libs/gtk+-3.9.10:3[introspection]
	>=x11-libs/libICE-1.0.1
	>=x11-libs/libnotify-0.7.0
	>=x11-libs/libSM-1.0.1
	>=x11-libs/libwnck-2.91.6:3
	x11-libs/libX11
	>=x11-libs/libXcomposite-0.4.5
	>=x11-libs/libXcursor-1.1.2
	>=x11-libs/libXdamage-1.1
	>=x11-libs/libXext-1.3.0
	>=x11-libs/libXfixes-4.0.1
	>=x11-libs/libXi-1.2.99.4
	x11-libs/libXinerama
	>=x11-libs/libXrandr-1.1.0.2
	>=x11-libs/libXrender-0.9.1
	>=x11-libs/pango-1.14.0[introspection]
	>=x11-libs/startup-notification-0.7
	>=x11-wm/metacity-3.22.0

	${PYTHON_DEPS}
	$(python_gen_cond_dep '>=dev-libs/libxml2-2.7.4:2[${PYTHON_USEDEP}]')
"
RDEPEND="${COMMON_DEPEND}
	>=dev-libs/atk-1.12.4
	>=dev-libs/libsigc++-2.2.0:2
	gnome-base/dconf
	>=gnome-base/gnome-settings-daemon-3.4.2
	media-libs/libglvnd
	>=sys-apps/dbus-1.9.14
	>=sys-devel/gcc-5.2
	>=sys-libs/glibc-2.33
	>=x11-libs/gdk-pixbuf-2.22.0:2[introspection]

	mate? ( mate-base/mate-settings-daemon )

	$(python_gen_cond_dep 'dev-python/pygobject:3[${PYTHON_USEDEP}]')
"
DEPEND="${COMMON_DEPEND}
	dev-libs/dbus-glib
	dev-perl/XML-Parser
	media-libs/mesa[gles2?]
	>=x11-base/xorg-proto-1.4.8
	>=x11-base/xorg-server-0.7.0

	!gles2? ( media-libs/glewmx:0= )

	$(python_gen_cond_dep '
		dev-libs/boost:=[python,${PYTHON_USEDEP}]
		dev-python/cython[${PYTHON_USEDEP}]
	')
"
BDEPEND="
	dev-util/intltool
	dev-build/libtool
	virtual/pkgconfig
"
PDEPEND="unity-base/unity[gles2=]"

S="${S}${UVER}"

MAKEOPTS="${MAKEOPTS} -j1"

src_prepare() {
	# Fix desktop freeze for Chromium, Chrome and Kodi when returning from fullscreen video when using proprietary gfx drivers #
	#  Related to Composite plugin - Unredirect Match, see https://askubuntu.com/questions/577459
	sed -i \
		-e 's:!(class=chromium-browser):!(class=chromium-browser) \&amp; !(class=Chromium-browser-chromium) \&amp; !(class=Google-chrome) \&amp; !(class=Kodi):' \
		plugins/composite/composite.xml.in || die

	# Set Expo y-offset according to Unity panel height #
	echo -e \
		"\n[org.compiz.expo]\ny-offset = 30" \
		>> debian/compiz-gnome.gsettings-override

	# Disable recompiling GSettings schemas inside sandbox #
	sed -i \
		-e "/# Recompile GSettings Schemas/,+6 d" \
		cmake/CompizGSettings.cmake || die
	grep -Fq "    endif (GSETTINGS_GLOBAL_INSTALL_DIR_SET)" \
		cmake/CompizGSettings.cmake || die

	# Disable updating icon cache inside sandbox #
	sed -i \
		-e "/# Update icon cache/,+11 d" \
		compizconfig/ccsm/setup.py || die
	grep -Fq "        length = 0" \
		compizconfig/ccsm/setup.py || die

	python_fix_shebang compizconfig/ccsm

	# Patchset already applied #
	> debian/patches/series

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
	CMAKE_BUILD_TYPE="RelWithDebInfo" cmake_src_configure
}

src_install() {
	cmake_src_install

	python_optimize

	local CMAKE_DIR=$(cmake --system-information | grep "^CMAKE_ROOT " | cut -d '"' -f 2)
	insinto "${CMAKE_DIR}"/Modules
	doins cmake/FindCompiz.cmake
	doins cmake/FindOpenGLES2.cmake
	doins compizconfig/libcompizconfig/cmake/FindCompizConfig.cmake

	insinto /usr/share/glib-2.0/schemas
	newins debian/compiz-gnome.gsettings-override 10_compiz-ubuntu.gschema.override

	insinto /usr/lib/compiz/migration
	doins postinst/convert-files/*.convert

	doman debian/{ccsm,compiz,gtk-window-decorator}.1

	use mate && dosym -r /usr/share/applications/compiz.desktop \
		/usr/share/mate/wm-properties/compiz.desktop
}
