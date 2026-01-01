# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=5build1

inherit multilib-minimal ubuntu-versionator

DESCRIPTION="OpenGL Extension Wrangler MX"
HOMEPAGE="https://glew.sourceforge.net/"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.debian.tar.xz"

LICENSE="BSD MIT"
SLOT="0/$(usub)"
KEYWORDS="amd64"
IUSE="doc static-libs"
RESTRICT="test"

RDEPEND="
	media-libs/libglvnd[${MULTILIB_USEDEP}]
	>=sys-libs/glibc-2.4[${MULTILIB_USEDEP}]
"
DEPEND="
	virtual/glu[${MULTILIB_USEDEP}]
	x11-libs/libX11[${MULTILIB_USEDEP}]
	x11-libs/libXi[${MULTILIB_USEDEP}]
	x11-libs/libXmu[${MULTILIB_USEDEP}]
"

S="${WORKDIR}/${PN%mx}-${PV}"

src_prepare() {
	sed -i \
		-e '/INSTALL/s:-s::' \
		-e '/$(CC) $(CFLAGS) -o/s:$(CFLAGS):$(CFLAGS) $(LDFLAGS):' \
		Makefile || die

	use static-libs || sed -i \
			-e '/glew.lib:/s|lib/$(LIB.STATIC) ||' \
			-e '/glew.lib.mx:/s|lib/$(LIB.STATIC.MX) ||' \
			-e '/INSTALL.*LIB.STATIC/d' \
			Makefile || die

	ubuntu-versionator_src_prepare

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

	einstalldocs

	if use doc; then
		docinto html
		dodoc doc/*
	fi

	# Prevent file collision with media-libs/glew #
	pushd "${ED}"/usr/include/GL >/dev/null || die
		mv glew.h glewmx.h || die
		mv glxew.h glxewmx.h || die
		mv wglew.h wglewmx.h || die
	popd >/dev/null || die
}
