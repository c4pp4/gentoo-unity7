# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

UVER=""
UREV="0ubuntu1"

inherit gnome2 ubuntu-versionator

DESCRIPTION="Monochrome icons for the Unity7 user interface (default icon theme)"
HOMEPAGE="https://launchpad.net/ubuntu-themes"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz
	yaru? ( ${UURL%/*}/yaru-theme-gtk_21.10.2_all.deb )"

LICENSE="GPL-3 CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+nemo +yaru"

RDEPEND="!x11-themes/light-themes
	x11-themes/hicolor-icon-theme"

DEPEND="${RDEPEND}
	unity-extra/ehooks
	x11-misc/icon-naming-utils
	dev-util/intltool
	sys-devel/gettext
	virtual/pkgconfig"

PDEPEND="nemo? ( gnome-extra/nemo )"

src_unpack() {
	default
	use yaru && tar -I zstd -xf "${PWD}"/data.tar.zst
}

src_prepare() {
	ubuntu-versionator_src_prepare

	## eog fullscreen toolbar background ##
	echo -e "\n/* eog fullscreen toolbar background */\noverlay > revealer > box > toolbar {\n background-color: @bg_color;\n}" \
		>> Ambiance/gtk-3.20/gtk-widgets.css

	## progress bar border when selected ##
	echo -e "\n/* progress bar border when selected */\nwindow.background box.vertical > scrolledwindow > treeview.view:focus .progressbar:selected:not(:backdrop) {\n border-color: @selected_fg_color;\n}" \
		>> Ambiance/gtk-3.20/gtk-widgets.css

	## nautilus selection and search bar ##
	echo $(<"${FILESDIR}"/nautilus.css) >> Ambiance/gtk-3.20/apps/nautilus.css

	## nautilus properties window background ##
	echo -e "\n/* nautilus properties window background */window.background.unified:dir(ltr) > deck:dir(ltr) > box.vertical.view:dir(ltr) {\n background-color: transparent;\n}" \
		>> Ambiance/gtk-3.20/gtk-widgets.css

	## workaround to avoid unwanted black frame when using HdyHeaderBar ##
	sed -i \
		-e "s/^decoration {$/.background.csd decoration {/" \
		Ambiance/gtk-3.20/gtk-widgets.css

	## remove HdyHeaderBar rounded top corners ##
	echo -e "\n/* remove HdyHeaderBar rounded top corners */\n.background:not(.tiled):not(.maximized):not(.solid-csd) headerbar.titlebar {\n border-top-left-radius: 0;\n border-top-right-radius: 0;\n}" \
		>> Ambiance/gtk-3.20/gtk-widgets.css

	## headerbar horizontal radio buttons ##
	echo -e "\n/* headerbar horizontal radio buttons */\nviewswitcher button > stack > box.wide {\n padding: 8px 12px;\n}\nheaderbar button.horizontal.radio {\n padding: 0;\n}" \
		>> Ambiance/gtk-3.20/gtk-widgets.css

	## baobab pathbar background ##
	echo -e "\n/* baobab pathbar background */\nheaderbar.windowhandle.titlebar .horizontal.pathbar button:not(:hover) {\n background-color: @dark_bg_color;\n}\nheaderbar.windowhandle.titlebar .horizontal.pathbar button {\n border-image-source: none;\n border-color: mix (@fg_color, @bg_color, 0.75);\n}" \
		>> Ambiance/gtk-3.20/gtk-widgets.css

	## add nemo nautilus-like theme ##
	use nemo && echo $(<"${FILESDIR}"/nemo.css) >> Ambiance/gtk-3.20/apps/nemo.css
}

src_configure() { :; }

src_compile() { default; }

src_install() {
	## Install icons ##
	insinto /usr/share/icons
	doins -r LoginIcons ubuntu-mono-dark ubuntu-mono-light

	## Add customized drop-down menu icon as "go-down-symbolic" ##
	##   from Adwaita theme is too dark since v3.30 ##
	doins -r "${FILESDIR}"/drop-down-icon/*

	insinto /usr/share/icons/suru
	doins -r suru-icons/*

	## Install themes ##
	insinto /usr/share/themes
	doins -r Ambiance Radiance ubuntu-mobile

	if use yaru; then
		## Add Yaru gtk4 theme ##
		insinto /usr/share/themes/Ambiance
		doins -r "${WORKDIR}"/usr/share/themes/Yaru-dark/gtk-4.0
		insinto /usr/share/themes/Radiance
		doins -r "${WORKDIR}"/usr/share/themes/Yaru/gtk-4.0
	fi

	## Remove broken symlinks ##
	find -L "${ED}" -type l -exec rm {} +

	einstalldocs
}
