# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
GNOME2_EAUTORECONF="yes"

UVER="+16.10.20160927"
UREV="0ubuntu5"

inherit gnome2 ubuntu-versionator vala

DESCRIPTION="Application lens for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/unity-lens-applications"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-libs/dee:=
	dev-libs/libcolumbus:=
	dev-libs/libunity:=
	dev-libs/libzeitgeist
	dev-libs/xapian:=
	gnome-base/gnome-menus:3
	gnome-extra/zeitgeist[datahub,fts]
	sys-libs/db:5.3
	unity-base/unity
	$(vala_depend)"

S="${WORKDIR}"

PATCHES=( "${FILESDIR}/${PN}-fix-build-against-vala-0.52.patch" )

src_prepare() {
	# Disable all language files as they can be incomplete #
	#  due to being provided by Ubuntu's language-pack packages #
	> po/LINGUAS

	ubuntu-versionator_src_prepare

	# Alter source to work with Gentoo's sys-libs/db slots #
	sed -e 's:"db.h":"db5.3/db.h":g' \
		-i configure || die
	sed -e 's:-ldb$:-ldb-5.3:g' \
		-i src/* || die
	sed -e 's:<db.h>:<db5.3/db.h>:g' \
		-i src/* || die
}

src_install() {
	local DOCS=( MAINTAINERS )
	default
	find "${ED}" -name '*.la' -delete || die
}
