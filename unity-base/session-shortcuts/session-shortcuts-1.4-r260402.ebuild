# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=build1
UREV=

inherit desktop xdg ubuntu-versionator

DESCRIPTION="Allows shutdown, logout, and reboot from dash"
HOMEPAGE="https://wiki.ubuntu.com/Unity"
SRC_URI="${UURL}.tar.xz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="test"

RDEPEND="
	!gnome-base/gnome-session
	gnome-extra/cinnamon-session
"
DEPEND="
	dev-util/intltool
	sys-devel/gettext
"
PDEPEND="unity-base/unity"

S="${S}${UVER}"

src_install() {
	local x
	for x in "${S}"/*.desktop.in; do
		# If a .desktop file does not have inline #
		# translations, fall back to calling gettext #
		echo "X-GNOME-Gettext-Domain=${PN}" >> "${x}"

		sed -i \
			-e "s/^_//" \
			-e "s/gnome-session-quit/unity-session-quit/" \
			"${x}" || die

		mv "${x}" "${x/%.in}" || die
	done

	domenu *.desktop
}
