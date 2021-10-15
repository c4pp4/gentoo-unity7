# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit gnome2-utils ubuntu-versionator xdg-utils

URELEASE="impish"
UVER=

DESCRIPTION="A nice and well polished icon theme"
HOMEPAGE="https://launchpad.net/human-icon-theme"
SRC_URI="${UURL}/${MY_P}.tar.xz"

LICENSE="CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="extra"
RESTRICT="mirror"

RDEPEND="x11-themes/adwaita-icon-theme
	extra? ( x11-themes/tangerine-icon-theme )"

src_install() {
	insinto /usr/share/icons
	doins -r Humanity
	doins -r Humanity-Dark

	## Remove broken symlinks ##
	find -L "${ED}" -type l -delete
}

pkg_postinst() {
	xdg_icon_cache_update
	ubuntu-versionator_pkg_postinst
}

pkg_postrm() { xdg_icon_cache_update; }
