# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=

inherit ubuntu-versionator

DESCRIPTION="Allows shutdown, logout, and reboot from dash"
HOMEPAGE="https://wiki.ubuntu.com/Unity"
SRC_URI="${UURL}.tar.xz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="test"

RDEPEND="
	gnome-base/gnome-session
	unity-base/unity
"
DEPEND="
	dev-util/intltool
	sys-devel/gettext
"

S="${WORKDIR}/${PN}-1.3"

src_configure() {
	./build.sh
}

src_install() {
	insinto /usr/share/applications
	doins build/*.desktop

	# If a .desktop file does not have inline #
	# translations, fall back to calling gettext #
	local x
	for x in "${ED}"/usr/share/applications/*.desktop; do
		echo "X-GNOME-Gettext-Domain=${PN}" >> "${x}"
	done
}
