# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

UVER=""
UREV=""

inherit ubuntu-versionator

DESCRIPTION="Allows shutdown, logout, and reboot from dash"
HOMEPAGE="http://unity.ubuntu.com/"
SRC_URI="${UURL}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-util/intltool
	sys-devel/gettext"

S="${WORKDIR}/${PN}-1.3"

src_configure() {
	./build.sh
}

src_install() {
	insinto /usr/share/applications
	doins build/*.desktop

	# If a .desktop file does not have inline
	# translations, fall back to calling gettext
	local file
	for file in "${ED%/}"/usr/share/applications/*.desktop; do
		echo "X-GNOME-Gettext-Domain=${PN}" >> "${file}"
	done
}
