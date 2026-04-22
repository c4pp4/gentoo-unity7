# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=~20260321+0b77e1b
UREV=1

inherit ubuntu-versionator

DESCRIPTION="Library to disable GTK client side decorations"
HOMEPAGE="https://codeberg.org/MorsMortium/gtk-nocsd"
SRC_URI="${UURL}.orig.tar.xz"

LICENSE="LGPL-2.1+ GPL-3+"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="test"

RDEPEND="
	>=dev-libs/glib-2.54.0:2
	>=sys-libs/glibc-2.34
"
DEPEND="gui-libs/libadwaita"

S="${S}${UVER}"

PATCHES=( "${FILESDIR}"/1fd10d1b03da423f0c7a4231fb82d848d8c52bb8...8cd6db74bc9b20d31e433b2e4a6ec05f9a402832.patch )

src_install() {
	emake \
		DESTDIR="${D}" \
		PREFIX=/usr \
		DOCDIR=/usr/share/doc/"${PF}" \
		NOOPT=1 \
		install

	einstalldocs

	exeinto /etc/X11/xinit/xinitrc.d
	doexe "${FILESDIR}"/51-gtk-nocsd
}
