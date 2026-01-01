# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=

inherit gnome2 ubuntu-versionator

DESCRIPTION="A nice and well polished icon theme"
HOMEPAGE="https://launchpad.net/human-icon-theme"
SRC_URI="${UURL}.tar.xz"

LICENSE="CC-BY-SA-3.0 GPL-2 GPL-3 LGPL-3+ MPL-1.1"
SLOT="0"
KEYWORDS="amd64"
IUSE="extra +optimize"
RESTRICT="binchecks strip test"

RDEPEND="
	x11-themes/adwaita-icon-theme
	x11-themes/hicolor-icon-theme

	extra? ( x11-themes/tangerine-icon-theme )
"
DEPEND="
	dev-python/pygobject:3
	gnome-base/librsvg

	optimize? (
		>=media-gfx/scour-0.36
		x11-misc/icon-naming-utils
	)
"

src_configure() { :; }

src_install() {
	# Add AdwaitaLegacy icons support #
	sed -i "s/Inherits=/Inherits=AdwaitaLegacy,/" Humanity/index.theme || die

	insinto /usr/share/icons
	doins -r Humanity
	doins -r Humanity-Dark

	# Fix unity-control-center printers panel icon #
	dosym -r /usr/share/icons/Humanity/devices/48/printer.svg \
		/usr/share/icons/Humanity/devices/48/printers.svg

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

	# Remove broken symlinks #
	find -L "${ED}" -type l -delete

	einstalldocs
}
