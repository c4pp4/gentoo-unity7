# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=

inherit meson xdg ubuntu-versionator

DESCRIPTION="Yaru icon theme from the Ubuntu Community"
HOMEPAGE="https://discourse.ubuntu.com/c/desktop/theme-refresh/18"
SRC_URI="${UURL}.tar.xz"

LICENSE="CC-BY-SA-4.0 GPL-3 LGPL-2.1 LGPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="cinnamon gnome-shell mate +unity xfwm"
RESTRICT="binchecks strip test"

RDEPEND="
	dev-libs/glib:2
	unity-base/session-migration
	x11-libs/gtk+:2
	x11-themes/gtk-engines-adwaita
	x11-themes/gtk-engines-murrine
"
BDEPEND="
	dev-libs/glib:2
	dev-lang/sassc
"

src_configure() {
	local emesonargs=(
		-Dgtk=true
		-Dgtksourceview=true
		-Dicons=true
		-Dmetacity=true
		-Dsessions=false
		-Dsounds=true
		$(meson_use cinnamon )
		$(meson_use cinnamon cinnamon-dark )
		$(meson_use cinnamon cinnamon-shell )
		$(meson_use gnome-shell )
		$(meson_use gnome-shell gnome-shell-gresource )
		$(meson_use mate )
		$(meson_use mate mate-dark )
		$(meson_use unity ubuntu-unity )
		$(meson_use xfwm xfwm4 )
	)
	meson_src_configure
}

src_install() {
	meson_src_install

	exeinto /usr/share/session-migration/scripts
	doexe debian/yaru-theme-gtk-abandon-Yaru-light.sh
}
