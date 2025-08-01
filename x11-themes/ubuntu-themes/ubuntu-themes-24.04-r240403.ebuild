# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=0ubuntu1

inherit gnome2 ubuntu-versionator

DESCRIPTION="Monochrome icons for the Unity7 user interface (default icon theme)"
HOMEPAGE="https://launchpad.net/ubuntu-themes"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3 CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="amd64"
IUSE="+optimize"
RESTRICT="binchecks strip test"

RDEPEND="
	x11-themes/adwaita-icon-theme
	x11-themes/gtk-engines-murrine
	x11-themes/hicolor-icon-theme
	x11-themes/humanity-icon-theme
	x11-themes/ubuntu-wallpapers
"
DEPEND="
	dev-python/pygobject:3
	gnome-base/librsvg
	x11-themes/yaru-theme[unity]

	optimize? (
		>=media-gfx/scour-0.36
		x11-misc/icon-naming-utils
	)
"

src_prepare() {
	## Add nemo nautilus-like theme ##
	cat "${FILESDIR}"/nemo.css >> \
		Ambiance/gtk-3.20/apps/nemo.css || die

	## Add widget fixes ##
	cat "${FILESDIR}"/gtk-widgets.css >> \
		Ambiance/gtk-3.20/gtk-widgets.css || die

	ubuntu-versionator_src_prepare
}

src_configure() { :; }

src_install() {
	## Install icons ##
	insinto /usr/share/icons
	doins -r LoginIcons ubuntu-mono-dark ubuntu-mono-light

	## Add customized drop-down menu icon as "go-down-symbolic", ##
	##   the one from Adwaita theme is too dark since v3.30 ##
	doins -r "${FILESDIR}"/drop-down-icon/*

	## Add Ambiance indicator-notifications icons ##
	doins -r "${FILESDIR}"/indicator-notifications/*

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

	## Ambiance symlinks to GTK4 Yaru theme ##
	dosym -r /usr/share/themes/Yaru-unity-ambiance/gtk-4.0 /usr/share/themes/Ambiance/gtk-4.0
	dosym -r /usr/share/icons/Yaru/scalable/ui/window-close-symbolic.svg /usr/share/icons/ubuntu-mono-dark/actions/16/window-close-symbolic.svg

	## Fallback color-scheme = 'prefer-dark' to Ambiance theme ##
	dosym -r /usr/share/themes/Ambiance/gtk-3.20/gtk.css /usr/share/themes/Ambiance/gtk-3.20/gtk-dark.css

	einstalldocs
}
