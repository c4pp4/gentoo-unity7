# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

UVER="+18.10.20180623"
UREV="0ubuntu3"

inherit autotools ubuntu-versionator xdummy

DESCRIPTION="Visual rendering toolkit for the Unity7 user interface"
HOMEPAGE="http://launchpad.net/nux"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3 LGPL-3"
SLOT="0/4"
KEYWORDS="~amd64"
IUSE="debug doc examples gles2 test"

DEPEND="app-i18n/ibus
	dev-cpp/gtest
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
	doc? ( app-doc/doxygen )
	!gles2? ( media-libs/glewmx )
	test? ( >=dev-cpp/gtest-1.8.1 )"

PDEPEND="unity-base/unity[gles2=]"

S="${WORKDIR}"

src_prepare() {
	ubuntu-versionator_src_prepare

	# Use headers from media-libs/glewmx package #
	local mxver="$(portageq best_version / media-libs/glewmx | cut -d "-" -f 3)"
	mxver="${mxver%%_*}"
	[[ -n mxver ]] && sed -i \
		-e "s:GL/glew.h:GL/glew-${mxver}.h:" \
		-e "s:GL/glxew.h:GL/glxew-${mxver}.h:" \
		-e "s:GL/wglew.h:GL/wglew-${mxver}.h:" \
		$(grep -lr -- "GL/.*gl.*ew.h" "${WORKDIR}")

	# Keep warnings as warnings, not failures #
	# Fix typo #
	sed -i \
		-e 's:-Werror ::g' \
		-e 's:AM_CXXFLAGS-:AM_CXXFLAGS=:' \
		configure.ac
	eautoreconf
}

src_configure() {
	use debug \
		&& myconf="${myconf}
			--enable-debug=yes"
	use doc \
		&& myconf="${myconf}
			--enable-documentation=yes"
	use examples \
		|| myconf="${myconf}
			--enable-examples=no"
	use gles2 \
		&& myconf="${myconf}
			--enable-opengles-20=yes"
	use test \
		|| myconf="${myconf}
			--enable-tests=no
			--enable-gputests=no"
	econf ${myconf}
}

src_test() {
	local XDUMMY_COMMAND="make check"
	xdummymake
}

src_install() {
	default
	dosym /usr/libexec/nux/unity_support_test /usr/$(get_libdir)/nux/unity_support_test

	## Install gfx hardware support test script ##
	sed -e "s:xubuntu:xunity:g" \
		-e "s:/usr/lib/:/usr/$(get_libdir)/:g" \
			-i debian/50_check_unity_support
	exeinto /etc/X11/xinit/xinitrc.d/
	doexe debian/50_check_unity_support

	find "${ED}" -name '*.la' -delete || die
}
