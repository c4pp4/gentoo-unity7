# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
GNOME2_EAUTORECONF="yes"

UVER="+21.10.20210712"
UREV="0ubuntu1"

inherit gnome2 ubuntu-versionator

DESCRIPTION="GSettings desktop-wide schemas for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/gsettings-ubuntu-touch-schemas"

LICENSE="LGPL-2.1"
SLOT="0"
IUSE=""
KEYWORDS="~amd64"

RDEPEND="sys-auth/polkit-pkla-compat"
DEPEND="${RDEPEND}
	gnome-base/dconf
	sys-devel/gettext
	>=dev-util/intltool-0.40
	virtual/pkgconfig"

S="${WORKDIR}"

src_configure() {
	econf --localstatedir=/var
}

src_install() {
	default
	find "${ED}" -name "*.pkla" -exec chown root:polkitd {} \;
}
