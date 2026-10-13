# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
GNOME2_EAUTORECONF="yes"

UVER=+21.10.20210712
UREV=0ubuntu4

inherit gnome2 ubuntu-versionator

DESCRIPTION="GSettings desktop-wide schemas for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/gsettings-ubuntu-touch-schemas"
S="${WORKDIR}"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="amd64"

RDEPEND="
	gnome-base/dconf
	sys-apps/accountsservice
	sys-auth/polkit
"
DEPEND=">=dev-libs/glib-2.13.0:2"
BDEPEND="
	acct-group/polkitd
	>=dev-util/intltool-0.40.0
	gnome-base/gnome-common
	virtual/pkgconfig
"

src_configure() {
	local myeconfargs=(
		--localstatedir="/var"
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default
	fowners root:polkitd /var/lib/polkit-1/localauthority/10-vendor.d/50-com.ubuntu.AccountsService.pkla
}
