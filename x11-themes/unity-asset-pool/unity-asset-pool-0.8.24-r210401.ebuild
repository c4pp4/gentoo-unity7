# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

UVER=+17.10.20170507
UREV=0ubuntu3

inherit xdg ubuntu-versionator

DESCRIPTION="Unity7 user interface icon theme"
HOMEPAGE="https://launchpad.net/unity-asset-pool"

LICENSE="CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="${RESTRICT} binchecks strip test"

RDEPEND="
	x11-themes/adwaita-icon-theme
	x11-themes/hicolor-icon-theme
"
DEPEND="
	>=media-gfx/scour-0.36
	x11-misc/icon-naming-utils
"

S="${WORKDIR}"

src_install() {
	local DOCS=( COPYRIGHT )
	default

	insinto /usr/share/unity/themes
	doins -r launcher/* panel/*

	insinto /usr/share/icons
	doins -r unity-icon-theme

	# Optimize icons #
	local x

	for x in "${ED}"/usr/share/icons/*/*/*/*.svg; do
		[[ -f ${x} ]] && ( scour -i "${x}" -o "${x}.tmp" && mv "${x}.tmp" "${x}" || rm "${x}.tmp" )
	done

	for x in "${ED}"/usr/share/icons/*/*/*; do
		[[ -d ${x} ]] && "${EROOT}"/usr/libexec/icon-name-mapping -c "${x}"
	done

	# Remove broken symlinks #
	find -L "${ED}" -type l -delete
}
