# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
GNOME2_EAUTORECONF="yes"

UVER=+21.10.20210712
UREV=0ubuntu3

inherit gnome2 ubuntu-versionator

DESCRIPTION="GSettings desktop-wide schemas for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/gsettings-ubuntu-touch-schemas"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	gnome-base/dconf
	sys-apps/accountsservice
"
DEPEND="
	>=dev-libs/glib-2.13.0:2
	gnome-base/gnome-common
"
BDEPEND=">=dev-util/intltool-0.40.0"

S="${WORKDIR}"

src_configure() {
	local myeconfargs=(
		--localstatedir="/var"
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default
	find "${ED}" -name "*.pkla" -exec chown root:polkitd {} \;
}
