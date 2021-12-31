# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
GNOME2_EAUTORECONF="yes"

UVER="+17.10.20170605"
UREV="0ubuntu2"

inherit gnome2 ubuntu-versionator vala

DESCRIPTION="File lens for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/unity-lens-files"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="dev-libs/dee:=
	dev-libs/libunity:="
DEPEND="${RDEPEND}
	dev-libs/libgee
	dev-libs/libzeitgeist
	>=gnome-extra/zeitgeist-0.9.14[datahub,fts]
	unity-base/unity
	unity-lenses/unity-lens-applications
	$(vala_depend)"

S="${WORKDIR}"

src_prepare() {
	# Disable all language files as they can be incomplete #
	#  due to being provided by Ubuntu's language-pack packages #
	> po/LINGUAS

	ubuntu-versionator_src_prepare
}
