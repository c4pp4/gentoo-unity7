# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

UVER=""
UREV="4ubuntu3"

inherit multilib-minimal ubuntu-versionator

DESCRIPTION="OpenGL Extension Wrangler MX"
HOMEPAGE="http://glew.sourceforge.net/"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.debian.tar.xz"

LICENSE="BSD MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc static-libs"

DEPEND="
	>=virtual/glu-9.0-r1[${MULTILIB_USEDEP}]
	>=virtual/opengl-7.0-r1[${MULTILIB_USEDEP}]
	>=x11-libs/libX11-1.6.2[${MULTILIB_USEDEP}]
	>=x11-libs/libXi-1.7.2[${MULTILIB_USEDEP}]
	>=x11-libs/libXmu-1.1.1-r1[${MULTILIB_USEDEP}]
"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN%mx}-${PV}"

src_prepare() {
	ubuntu-versionator_src_prepare

	sed -i \
		-e '/INSTALL/s:-s::' \
		-e '/$(CC) $(CFLAGS) -o/s:$(CFLAGS):$(CFLAGS) $(LDFLAGS):' \
		Makefile || die

	use static-libs || sed -i \
			-e '/glew.lib:/s|lib/$(LIB.STATIC) ||' \
			-e '/glew.lib.mx:/s|lib/$(LIB.STATIC.MX) ||' \
			-e '/INSTALL.*LIB.STATIC/d' \
			Makefile || die

	default
	multilib_copy_sources
}

set_opts() {
	myglewopts=(
		AR="$(tc-getAR)"
		STRIP=true
		CC="$(tc-getCC)"
		LD="$(tc-getCC) ${LDFLAGS}"
		SYSTEM="linux"
		M_ARCH=""
		LDFLAGS.EXTRA=""
		POPT="${CFLAGS}"
	)
}

multilib_src_compile() {
	set_opts
	emake glew.lib.mx \
		GLEW_DEST="${EPREFIX}/usr" \
		LIBDIR="${EPREFIX}/usr/$(get_libdir)" \
		"${myglewopts[@]}"
}

multilib_src_install() {
	set_opts
	emake \
		GLEW_DEST="${ED}/usr" \
		LIBDIR="${ED}/usr/$(get_libdir)" \
		"${myglewopts[@]}" \
		install.mx

	local DOCS=( LICENSE.txt )
	einstalldocs

	if use doc; then
		docinto html
		dodoc doc/*
	fi

	# Prevent file collision with media-libs/glew #
	local mxver="${PV%%_*}"
	pushd "${ED}"/usr/include/GL 1>/dev/null || die
		mv glew.h glew-"${mxver}".h
		mv glxew.h glxew-"${mxver}".h
		mv wglew.h wglew-"${mxver}".h
	popd 1>/dev/null
}
