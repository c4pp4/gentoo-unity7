# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
GNOME2_EAUTORECONF="yes"

UVER=+17.10.20170605
UREV=0ubuntu6

inherit gnome2 ubuntu-versionator vala

DESCRIPTION="File lens for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/unity-lens-files"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"
S="${WORKDIR}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="test"
RESTRICT="!test? ( test )"

COMMON_DEPEND="
	>=dev-libs/dee-1.0.0:0=
	>=dev-libs/glib-2.37.3:2
	>=dev-libs/libgee-0.8.3:0.8
	>=dev-libs/libunity-7.0.0:0=
	>=gnome-extra/zeitgeist-0.9.12[datahub,fts]
"
RDEPEND="${COMMON_DEPEND}
	gnome-base/dconf
"
DEPEND="${COMMON_DEPEND}"
BDEPEND="
	dev-util/intltool
	sys-devel/gettext
	virtual/pkgconfig
	$(vala_depend)
"

PATCHES=( "${FILESDIR}"/remove-1kb-filter-option.patch )

src_prepare() {
	# Disable all language files as they can be incomplete #
	#  due to being provided by Ubuntu's language-pack packages #
	> po/LINGUAS || die

	ubuntu-versionator_src_prepare
}
