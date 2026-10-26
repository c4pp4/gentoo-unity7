# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=build1
UREV=

inherit gnome2 ubuntu-versionator

DESCRIPTION="A nice and well polished icon theme"
HOMEPAGE="https://launchpad.net/human-icon-theme"
SRC_URI="${UURL}.tar.xz"
S="${S}${UVER}"

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
BDEPEND="
	optimize? (
		>=media-gfx/scour-0.36
		x11-misc/icon-naming-utils
	)
"

src_prepare() {
	# Add AdwaitaLegacy icons support #
	sed -i "s/Inherits=/Inherits=AdwaitaLegacy,/" Humanity/index.theme || die
	grep -q "^Inherits=AdwaitaLegacy," Humanity/index.theme || die

	ubuntu-versionator_src_prepare
}

src_configure() { :; }

src_install() {
	insinto /usr/share/icons
	doins -r Humanity
	doins -r Humanity-Dark

	# Fix unity-control-center printers panel icon #
	# 'printer' resolves to printer-symbolic of ubuntu-mono-* and Yaru-*-dark #
	# (GThemedIcon adds -symbolic fallbacks), 'printers' has no symbolic variant #
	dosym -r /usr/share/icons/Humanity/devices/48/printer.svg \
		/usr/share/icons/Humanity/devices/48/printers.svg

	# Optimize icons #
	if use optimize; then
		local x

		for x in "${ED}"/usr/share/icons/*/*/*/*.svg; do
			if [[ -f ${x} ]]; then
				scour -i "${x}" -o "${x}.tmp" 2>/dev/null && mv "${x}.tmp" "${x}" || rm "${x}.tmp"
			fi
		done

		for x in "${ED}"/usr/share/icons/*/*/*; do
			[[ -d ${x} ]] && "${BROOT}"/usr/libexec/icon-name-mapping -c "${x}"
		done
	fi

	# Remove broken symlinks #
	find -L "${ED}" -type l -delete || die

	einstalldocs
}
