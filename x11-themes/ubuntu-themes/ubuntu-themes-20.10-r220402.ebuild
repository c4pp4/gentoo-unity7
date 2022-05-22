# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

UVER=
UREV=0ubuntu2

inherit gnome2 ubuntu-versionator

DESCRIPTION="Monochrome icons for the Unity7 user interface (default icon theme)"
HOMEPAGE="https://launchpad.net/ubuntu-themes"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3 CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+nemo +optimize"
RESTRICT="${RESTRICT} binchecks strip test"

RDEPEND="
	x11-themes/adwaita-icon-theme
	x11-themes/hicolor-icon-theme
	x11-themes/humanity-icon-theme
	x11-themes/ubuntu-wallpapers
"
DEPEND="
	dev-python/pygobject:3
	gnome-base/librsvg
	x11-themes/yaru-unity7

	optimize? (
		>=media-gfx/scour-0.36
		x11-misc/icon-naming-utils
	)
"
PDEPEND="nemo? ( gnome-extra/nemo )"

src_prepare() {
	## Add nemo nautilus-like theme ##
	use nemo && echo $(<"${FILESDIR}"/nemo.css) >> Ambiance/gtk-3.20/apps/nemo.css

	## Workaround to avoid unwanted black frame when using HdyHeaderBar ##
	sed -i \
		-e "s/^decoration {$/.background.csd decoration {/" \
		Ambiance/gtk-3.20/gtk-widgets.css

	## eog fullscreen toolbar background ##
	echo -e "\n/* eog fullscreen toolbar background */\noverlay > revealer > box > toolbar {\n background-color: @bg_color;\n}" \
		>> Ambiance/gtk-3.20/gtk-widgets.css

	## Progress bar border when selected ##
	echo -e "\n/* progress bar border when selected */\nwindow.background box.vertical > scrolledwindow > treeview.view:focus .progressbar:selected:not(:backdrop) {\n border-color: @selected_fg_color;\n}" \
		>> Ambiance/gtk-3.20/gtk-widgets.css

	## nautilus selection and search bar ##
	echo $(<"${FILESDIR}"/nautilus.css) >> Ambiance/gtk-3.20/apps/nautilus.css

	## nautilus properties window background ##
	echo -e "\n/* nautilus properties window background */window.background.unified:dir(ltr) > deck:dir(ltr) > box.vertical.view:dir(ltr) {\n background-color: transparent;\n}" \
		>> Ambiance/gtk-3.20/gtk-widgets.css

	## Remove HdyHeaderBar rounded top corners ##
	echo -e "\n/* remove HdyHeaderBar rounded top corners */\n.background:not(.tiled):not(.maximized):not(.solid-csd) headerbar.titlebar {\n border-top-left-radius: 0;\n border-top-right-radius: 0;\n}" \
		>> Ambiance/gtk-3.20/gtk-widgets.css

	## headerbar horizontal radio buttons ##
	echo -e "\n/* headerbar horizontal radio buttons */\nviewswitcher button > stack > box.wide {\n padding: 8px 12px;\n}\nheaderbar button.horizontal.radio {\n padding: 0;\n}" \
		>> Ambiance/gtk-3.20/gtk-widgets.css

	## baobab pathbar background ##
	echo -e "\n/* baobab pathbar background */\nheaderbar.windowhandle.titlebar .horizontal.pathbar button:not(:hover) {\n background-color: @dark_bg_color;\n}\nheaderbar.windowhandle.titlebar .horizontal.pathbar button {\n border-image-source: none;\n border-color: mix (@fg_color, @bg_color, 0.75);\n}" \
		>> Ambiance/gtk-3.20/gtk-widgets.css

	ubuntu-versionator_src_prepare
}

src_configure() { :; }

src_install() {
	## Install icons ##
	insinto /usr/share/icons
	doins -r LoginIcons ubuntu-mono-dark ubuntu-mono-light

	## Add customized drop-down menu icon as "go-down-symbolic" ##
	##   from Adwaita theme is too dark since v3.30 ##
	doins -r "${FILESDIR}"/drop-down-icon/*

	insinto /usr/share/icons/suru
	doins -r suru-icons/*

	# Optimize icons #
	if use optimize; then
		local x

		for x in "${ED}"/usr/share/icons/*/*/*/*.svg; do
			[[ -f ${x} ]] && ( scour -i "${x}" -o "${x}.tmp" && mv "${x}.tmp" "${x}" || rm "${x}.tmp" )
		done

		for x in "${ED}"/usr/share/icons/*/*/*; do
			[[ -d ${x} ]] && "${EROOT}"/usr/libexec/icon-name-mapping -c "${x}"
		done
	fi

	## Install themes ##
	insinto /usr/share/themes
	doins -r Ambiance Radiance ubuntu-mobile

	## Remove broken symlinks ##
	find -L "${ED}" -type l -delete

	## Add gtk4 theme from yaru-unity7 ##
	dosym ../Yaru-unity-dark/gtk-4.0 /usr/share/themes/Ambiance/gtk-4.0
	dosym ../Yaru-unity/gtk-4.0 /usr/share/themes/Radiance/gtk-4.0

	einstalldocs
}
