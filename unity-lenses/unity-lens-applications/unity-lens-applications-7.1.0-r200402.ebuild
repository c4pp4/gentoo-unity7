# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
GNOME2_EAUTORECONF="yes"

UVER=+16.10.20160927
UREV=0ubuntu5

inherit gnome2 ubuntu-versionator vala

DESCRIPTION="Application lens for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/unity-lens-applications"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"

COMMON_DEPEND="
	>=dev-libs/dee-1.0.2:0=
	>=dev-libs/glib-2.43.92:2
	>=dev-libs/libcolumbus-1.1.0:0=
	>=dev-libs/libgee-0.8.3:0.8
	>=dev-libs/libunity-7.1.4:0=
	>=dev-libs/libzeitgeist-0.3.8
	>=dev-libs/xapian-1.4.14:=
	>=gnome-base/gnome-menus-3.2.0.1:3
"
RDEPEND="${COMMON_DEPEND}
	gnome-base/dconf
	>=sys-devel/gcc-5.2
	sys-libs/db:5.3
	>=sys-libs/glibc-2.14
"
DEPEND="${COMMON_DEPEND}
	gnome-base/gnome-common

	$(vala_depend)
"
BDEPEND="virtual/pkgconfig"

S="${WORKDIR}"

PATCHES=(
	"${FILESDIR}"/fix-build-against-vala-0.52.patch
	"${FILESDIR}"/remove-software-center-filter-option.patch
)

src_prepare() {
	# Remove failed test #
	sed -i \
		-e "/test ~username expansion/,+4 d" \
		tests/unit/test-utils.vala || die

	# Fix build against vala-0.56.4 #
	sed -i \
		-e '/public delegate bool AppFilterCallback/i \    [CCode (cheader_filename = "unity-package-search.h")]' \
		vapi/unity-package-search.vapi || die

	# Disable all language files as they can be incomplete #
	#  due to being provided by Ubuntu's language-pack packages #
	> po/LINGUAS

	ubuntu-versionator_src_prepare

	# Alter source to work with Gentoo's sys-libs/db slots #
	sed -i 's:"db.h":"db5.3/db.h":g' configure || die
	sed -i 's:-ldb$:-ldb-5.3:g' src/* || die
	sed -i 's:<db.h>:<db5.3/db.h>:g' src/* || die
}

src_install() {
	local DOCS=( MAINTAINERS )
	default

	find "${ED}" -name '*.la' -delete || die
}
