# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

UVER="+17.10.20170507"
UREV="0ubuntu3"

inherit ubuntu-versionator xdg-utils

DESCRIPTION="Unity7 user interface icon theme"
HOMEPAGE="https://launchpad.net/unity-asset-pool"

LICENSE="CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="x11-themes/adwaita-icon-theme
	x11-themes/hicolor-icon-theme"

BDEPEND="dev-util/intltool
	sys-devel/gettext
	virtual/pkgconfig"

S="${WORKDIR}"

src_install() {
	insinto /usr/share/unity/themes
	doins -r launcher/* panel/*

	insinto /usr/share/icons
	doins -r unity-icon-theme

	local DOCS=( COPYRIGHT )
	einstalldocs
}

pkg_postinst() {
	xdg_icon_cache_update
	ubuntu-versionator_pkg_postinst
}

pkg_postrm() { xdg_icon_cache_update; }
