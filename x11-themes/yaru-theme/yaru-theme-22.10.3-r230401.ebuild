# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=1

inherit meson xdg ubuntu-versionator

DESCRIPTION="Yaru theme from the Ubuntu Community"
HOMEPAGE="https://discourse.ubuntu.com/c/desktop/theme-refresh"

LICENSE="CC-BY-SA-4.0 GPL-3 LGPL-2.1 LGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cinnamon gnome-shell mate +unity xfwm"
RESTRICT="binchecks strip test"

RDEPEND="
	dev-libs/glib:2
	x11-libs/gtk+:2
	x11-themes/gtk-engines-adwaita
	x11-themes/gtk-engines-murrine
"
BDEPEND="
	dev-libs/glib:2
	dev-lang/sassc
"

S="${WORKDIR}/${P/-theme}"

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
