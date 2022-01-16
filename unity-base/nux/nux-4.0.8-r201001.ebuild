# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
UBUNTU_EAUTORECONF="yes"

UVER="+18.10.20180623"
UREV="0ubuntu3"

inherit ubuntu-versionator

DESCRIPTION="Visual rendering toolkit for the Unity7 user interface"
HOMEPAGE="http://launchpad.net/nux"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3 LGPL-3"
SLOT="0/4"
KEYWORDS="~amd64"
IUSE="debug doc examples gles2"
RESTRICT="${RESTRICT} test"

DEPEND="
	app-i18n/ibus
	dev-libs/boost:=
	dev-libs/glib:2
	dev-libs/libpcre
	dev-libs/libsigc++:2
	gnome-base/gnome-common
	media-libs/libpng:0
	sys-apps/pciutils
	unity-base/geis
	x11-base/xorg-proto
	x11-libs/cairo
	x11-libs/gdk-pixbuf
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXxf86vm
	x11-libs/pango
	!gles2? (
		media-libs/glewmx
	)
"
BDEPEND="
	doc? (
		app-doc/doxygen
	)
"
PDEPEND="
	unity-base/unity[gles2=]
"

S="${WORKDIR}"

src_prepare() {
	# Use headers from media-libs/glewmx package #
	local mxver="$(portageq best_version / media-libs/glewmx | cut -d "-" -f 3)"
	[[ -n mxver ]] && sed -i \
		-e "s:GL/glew.h:GL/glew-${mxver}.h:" \
		-e "s:GL/glxew.h:GL/glxew-${mxver}.h:" \
		-e "s:GL/wglew.h:GL/wglew-${mxver}.h:" \
		$(grep -Elr -- "GL/w?glx?ew.h" "${WORKDIR}") || die

	# Fix typo #
	sed -i \
		-e 's:AM_CXXFLAGS-:AM_CXXFLAGS=:' \
		configure.ac || die

	ubuntu-versionator_src_prepare

	## Fix libdir ##
	sed -i \
		-e "s:xubuntu:xunity:" \
		-e "s:/usr/lib/:/usr/$(get_libdir)/:" \
		debian/50_check_unity_support || die
}

src_configure() {
	econf \
		--enable-debug=$(usex debug) \
		--enable-documentation=$(usex doc) \
		--enable-examples=$(usex examples) \
		--enable-gputests=no \
		--enable-opengles-20=$(usex gles2) \
		--enable-tests=no
}

src_install() {
	default

	dosym ../../libexec/nux/unity_support_test \
		/usr/$(get_libdir)/nux/unity_support_test

	# Install gfx hardware support test script #
	exeinto /etc/X11/xinit/xinitrc.d/
	doexe debian/50_check_unity_support

	find "${ED}" -name '*.la' -delete || die
}
