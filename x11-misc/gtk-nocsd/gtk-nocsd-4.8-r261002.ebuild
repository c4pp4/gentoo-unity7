# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=1

inherit toolchain-funcs ubuntu-versionator

DESCRIPTION="Library to disable GTK client side decorations"
HOMEPAGE="https://codeberg.org/MorsMortium/gtk-nocsd"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.debian.tar.xz"
S="${WORKDIR}/${PN}"

LICENSE="LGPL-2.1+ GPL-3+"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="test"

RDEPEND=">=dev-libs/glib-2.54.0:2"
DEPEND="
	${RDEPEND}
	>=gui-libs/libadwaita-1.5
"
BDEPEND="virtual/pkgconfig"

src_compile() {
	emake \
		CC="$(tc-getCC)" \
		PKG_CONFIG="$(tc-getPKG_CONFIG)"
}

src_install() {
	emake \
		DESTDIR="${D}" \
		PREFIX=/usr \
		LIBDIR=/usr/$(get_libdir) \
		DOCDIR=/usr/share/doc/"${PF}" \
		NOOPT=1 \
		install

	# Already installed as a doc #
	rm -r "${ED}"/usr/share/licenses || die

	einstalldocs

	exeinto /etc/X11/xinit/xinitrc.d
	doexe "${FILESDIR}"/51-gtk-nocsd
}
