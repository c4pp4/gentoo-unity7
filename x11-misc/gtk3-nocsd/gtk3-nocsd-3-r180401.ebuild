# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=1ubuntu1

inherit ubuntu-versionator

DESCRIPTION="Disable Gtk+ 3 client side decorations (CSD)"
HOMEPAGE="https://github.com/PCMan/gtk3-nocsd"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.debian.tar.xz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="test"

RDEPEND=">=sys-libs/glibc-2.4"
DEPEND="
	dev-libs/glib:2
	x11-libs/gtk+:3[introspection]
"

PATCHES=( "${FILESDIR}"/version-4.patch )

src_prepare() {
	# Fix libdir (prefix and LD_PRELOAD) #
	local fixlib=$(get_libdir)
	sed -i \
		-e "s:/local::" \
		-e "\:(prefix):{s:/lib:/${fixlib}:}" \
		Makefile || die
	sed -i \
		-e "s:\(libgtk3-nocsd.so.0\):/usr/${fixlib}/\1:" \
		"${WORKDIR}"/debian/extra/51gtk3-nocsd-detect || die

	# Tweak manpage #
	sed -i \
		-e "s/ IN DEBIAN//" \
		-e "s/ in Debian//" \
		-e "s:Xsession.d:xinit/xinitrc.d:" \
		-e "s:gtk3-nocsd/README.Debian:${P}/README.md.bz2:" \
		"${WORKDIR}"/debian/patches/debian-specifics-in-manpage.patch || die

	ubuntu-versionator_src_prepare
}

src_install() {
	default

	exeinto /etc/X11/xinit/xinitrc.d
	doexe "${WORKDIR}"/debian/extra/01gtk3-nocsd
	doexe "${WORKDIR}"/debian/extra/51gtk3-nocsd-detect
	doexe "${WORKDIR}"/debian/extra/70gtk3-nocsd-propagate-LD_PRELOAD
}
