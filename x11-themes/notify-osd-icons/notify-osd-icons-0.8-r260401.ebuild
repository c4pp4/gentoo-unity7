# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=+15.10.20151016.2
UREV=0ubuntu4

inherit ubuntu-versionator

DESCRIPTION="Icons for on-screen-display notification agent"
HOMEPAGE="https://launchpad.net/notify-osd"

LICENSE="CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="binchecks strip test"

DEPEND="media-gfx/scour"

S="${S}${UVER}"

src_install() {
	default

	# Source: debian/notify-osd-icons.links #
	local \
		path=/usr/share/notify-osd/icons/Humanity/scalable/status \
		x

	# Optimize SVG files #
	for x in "${ED}${path}"/*.svg; do
		if [[ -f ${x} ]]; then
			scour -i "${x}" -o "${x}.tmp" 2>/dev/null && mv "${x}.tmp" "${x}" || rm "${x}.tmp"
		fi
	done

	dosym notification-battery-000.svg ${path}/notification-battery-empty.svg
	dosym notification-battery-020.svg ${path}/notification-battery-low.svg
}
