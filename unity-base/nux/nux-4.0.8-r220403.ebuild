# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
UBUNTU_EAUTORECONF="yes"

UVER=+18.10.20180623
UREV=0ubuntu4

inherit ubuntu-versionator

DESCRIPTION="Visual rendering toolkit for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/nux"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3 LGPL-2.1 LGPL-3"
SLOT="0/$(usub)"
KEYWORDS="amd64"
IUSE="debug doc examples gles2"
RESTRICT="test"

COMMON_DEPEND="
	>=app-i18n/ibus-1.5.1
	dev-libs/boost:=
	>=dev-libs/glib-2.31.8:2
	dev-libs/libpcre:3
	>=dev-libs/libsigc++-2.8.0:2
	media-libs/libpng:0=
	>=sys-apps/pciutils-3.5.1
	>=unity-base/geis-2.2.10
	virtual/glu
	>=x11-libs/cairo-1.9.14
	>=x11-libs/gdk-pixbuf-2.22.0:2
	x11-libs/libX11
	>=x11-libs/libXcomposite-0.4.5
	>=x11-libs/libXdamage-1.1
	x11-libs/libXinerama
	x11-libs/libXxf86vm
	>=x11-libs/pango-1.20.0

	!gles2? (
		>=media-libs/glew-2.0.0:0=
		>=media-libs/glewmx-1.12.0:0=
	)
"
RDEPEND="${COMMON_DEPEND}
	media-libs/libglvnd
	>=sys-devel/gcc-5.2
	>=sys-libs/glibc-2.29
	x11-libs/libXext
	x11-libs/libXfixes
"
DEPEND="${COMMON_DEPEND}
	gnome-base/gnome-common
	x11-libs/libXtst

	gles2? ( media-libs/mesa[gles2] )
"
BDEPEND="doc? ( app-doc/doxygen[dot] )"
PDEPEND="unity-base/unity[gles2=]"

S="${WORKDIR}"

src_prepare() {
	# Use headers from media-libs/glewmx package #
	sed -i \
		-e "s:GL/glew.h:GL/glewmx.h:" \
		-e "s:GL/glxew.h:GL/glxewmx.h:" \
		-e "s:GL/wglew.h:GL/wglewmx.h:" \
		$(grep -Elr -- "GL/w?glx?ew.h" "${WORKDIR}") || die

	# Fix typo #
	sed -i 's:AM_CXXFLAGS-:AM_CXXFLAGS=:' configure.ac || die

	ubuntu-versionator_src_prepare

	sed -i \
		-e "s:xubuntu:xunity:" \
		-e "s:/usr/lib/:/usr/$(get_libdir)/:" \
		debian/50_check_unity_support || die
}

src_configure() {
	local myeconfargs=(
		--enable-debug=$(usex debug)
		--enable-documentation=$(usex doc)
		--enable-examples=$(usex examples)
		--enable-gputests=no
		--enable-opengles-20=$(usex gles2)
		--enable-tests=no
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default

	dosym -r /usr/libexec/nux/unity_support_test \
		/usr/$(get_libdir)/nux/unity_support_test

	# Install gfx hardware support test script #
	exeinto /etc/X11/xinit/xinitrc.d/
	doexe debian/50_check_unity_support

	find "${ED}" -name '*.la' -delete || die
}
