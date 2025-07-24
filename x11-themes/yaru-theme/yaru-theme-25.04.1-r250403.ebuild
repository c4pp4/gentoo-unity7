# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=0ubuntu1

inherit meson xdg ubuntu-versionator

DESCRIPTION="Yaru theme from the Ubuntu Community"
HOMEPAGE="https://discourse.ubuntu.com/c/desktop/theme-refresh"
SRC_URI="${UURL}-${UREV}.tar.xz"

LICENSE="CC-BY-SA-4.0 GPL-3 LGPL-2.1 LGPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="cinnamon gnome-shell gtk mate +unity xfwm"
RESTRICT="binchecks strip test"

RDEPEND="
	dev-libs/glib:2
	unity-base/session-migration
	x11-libs/gtk+:2
	x11-themes/gtk-engines-adwaita
	x11-themes/gtk-engines-murrine

	gtk? ( sys-apps/xdg-desktop-portal-gtk )
"
BDEPEND="
	dev-libs/glib:2
	dev-libs/libxml2:2
	dev-lang/sassc
"

S="${WORKDIR}/${PN}-${UREV}"

PATCHES=(
	"${FILESDIR}"/Adjust-window-shadow-and-bottom-corners.patch
	"${FILESDIR}"/Create-Ambiance-GTK-4.0-theme.patch
)

src_prepare() {
	## Fix mate-terminal background color ##
	sed -i \
		-e '/vte-terminal {/{n;s/$_mate_terminal_bg_color/#300A24/}' \
		gtk/src/default/gtk-3.0/apps/_mate-terminal.scss || die

	## Add nemo nautilus-like theme ##
	cat "${FILESDIR}"/nemo.css >> \
		gtk/src/default/gtk-3.0/apps/_nemo.scss || die

	## Add widget fixes ##
	cat "${FILESDIR}"/gtk-widgets.css >> \
		gtk/src/default/gtk-3.0/_tweaks.scss || die

	ubuntu-versionator_src_prepare

	## Orange close button for Ambiance ##
	mkdir -p gtk/src/unity-ambiance/gtk-4.0 || die
	cp -r gtk/src/default/gtk-4.0 gtk/src/unity-ambiance || die
	cat "${FILESDIR}"/_palette.scss >> \
		gtk/src/unity-ambiance/gtk-4.0/_palette.scss || die
	cat "${FILESDIR}"/_tweaks.scss >> \
		gtk/src/unity-ambiance/gtk-4.0/_tweaks.scss || die
}

src_configure() {
	local emesonargs=(
		-Dgnome-shell-user-themes-support=$(usex gnome-shell enabled disabled)
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
