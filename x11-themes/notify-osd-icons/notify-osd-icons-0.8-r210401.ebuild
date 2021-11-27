# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

UVER="+15.10.20151016.2"
UREV="0ubuntu3"

inherit ubuntu-versionator

DESCRIPTION="Icons for on-screen-display notification agent"
HOMEPAGE="http://launchpad.net/notify-osd"

LICENSE="CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="x11-misc/notify-osd"
DEPEND="media-gfx/scour"

S="${S}${UVER}"

src_install() {
	default

	# Source: debian/notify-osd-icons.links
	local path=/usr/share/notify-osd/icons/Humanity/scalable/status
	dosym notification-battery-000.svg ${path}/notification-battery-empty.svg
	dosym notification-battery-020.svg ${path}/notification-battery-low.svg

	# Optimize SVG files
	for f in "${ED}${path}"/*.svg; do
		[[ -f ${f} ]] && scour -i "${f}" -o "${f}.tmp" && mv "${f}.tmp" "${f}" || rm "${f}.tmp"
	done
}
