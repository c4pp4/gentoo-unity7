# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

URELEASE="impish"
inherit eutils gnome2-utils ubuntu-versionator xdg-utils

DESCRIPTION="Monochrome icons for the Unity7 user interface (default icon theme)"
HOMEPAGE="https://launchpad.net/ubuntu-themes"
SRC_URI="${UURL}/${MY_P}${UVER_PREFIX}.orig.tar.gz
	${UURL}/${MY_P}${UVER_PREFIX}-${UVER}.diff.gz"

LICENSE="GPL-3 CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+nemo"
RESTRICT="mirror"

RDEPEND="!x11-themes/light-themes
	x11-themes/hicolor-icon-theme"

DEPEND="${RDEPEND}
	unity-extra/ehooks
	x11-misc/icon-naming-utils
	dev-util/intltool
	sys-devel/gettext
	virtual/pkgconfig"

PDEPEND="nemo? ( gnome-extra/nemo )"

src_prepare() {
	eapply "${WORKDIR}/${MY_P}${UVER_PREFIX}-${UVER}.diff"	# This needs to be applied for the debian/ directory to be present #
	ubuntu-versionator_src_prepare

	## eog fullscreen toolbar background ##
	echo -e "\n/* eog fullscreen toolbar background */\noverlay > revealer > box > toolbar {\n background-color: @bg_color;\n}" >> Ambiance/gtk-3.20/gtk-widgets.css

	## progress bar border when selected ##
	echo -e "\n/* progress bar border when selected */\nwindow.background box.vertical > scrolledwindow > treeview.view:focus .progressbar:selected:not(:backdrop) {\n border-color: @selected_fg_color;\n}" >> Ambiance/gtk-3.20/gtk-widgets.css

	## nautilus selection and search bar ##
	echo $(<"${FILESDIR}"/nautilus.css) >> Ambiance/gtk-3.20/apps/nautilus.css

	## nautilus properties window background ##
	echo -e "\n/* nautilus properties window background */window.background.unified:dir(ltr) > deck:dir(ltr) > box.vertical.view:dir(ltr) {\n background-color: transparent;\n}" >> Ambiance/gtk-3.20/gtk-widgets.css

	## workaround to avoid unwanted black frame when using HdyHeaderBar ##
	sed -i \
		-e "s/^decoration {$/.background.csd decoration {/" \
		Ambiance/gtk-3.20/gtk-widgets.css

	## remove HdyHeaderBar rounded top corners ##
	echo -e "\n/* remove HdyHeaderBar rounded top corners */\n.background:not(.tiled):not(.maximized):not(.solid-csd) headerbar.titlebar {\n border-top-left-radius: 0;\n border-top-right-radius: 0;\n}" >> Ambiance/gtk-3.20/gtk-widgets.css

	## headerbar horizontal radio buttons ##
	echo -e "\n/* headerbar horizontal radio buttons */\nviewswitcher button > stack > box.wide {\n padding: 8px 12px;\n}\nheaderbar button.horizontal.radio {\n padding: 0;\n}" >> Ambiance/gtk-3.20/gtk-widgets.css

	## baobab pathbar background ##
	echo -e "\n/* baobab pathbar background */\n@define-color theme_bg_color @dark_bg_color;\nheaderbar.windowhandle.titlebar .horizontal.pathbar button {\n border-image-source: none;\n border: 1px solid @fg_color;\n}" >> Ambiance/gtk-3.20/gtk-widgets.css
	
	use nemo && echo $(<"${FILESDIR}"/nemo.css) >> Ambiance/gtk-3.20/apps/nemo.css
}

src_configure() { :; }

src_compile() {
	emake
}

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

	## Remove broken symlinks ##
	find -L "${ED}" -type l -exec rm {} +
}

pkg_postinst() {
	xdg_icon_cache_update
	ubuntu-versionator_pkg_postinst
}

pkg_postrm() { xdg_icon_cache_update; }
