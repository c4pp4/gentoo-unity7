# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
UBUNTU_EAUTORECONF="yes"

UVER=+19.04.20190412
UREV=0ubuntu6

inherit vala ubuntu-versionator

DESCRIPTION="Home scope that aggregates results from multiple scopes for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/unity-scope-home"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="test"
RESTRICT="!test? ( test )"

COMMON_DEPEND="
	>=dev-libs/dee-1.2.7:0=
	>=dev-libs/glib-2.43.92:2
	>=dev-libs/json-glib-0.13.2
	>=dev-libs/libgee-0.8.3:0.8
	>=dev-libs/libunity-7.1.4:0=
	>=net-libs/libsoup-2.24.3:2.4
	sys-apps/lsb-release
	>=sys-apps/util-linux-2.16
"
RDEPEND="${COMMON_DEPEND}
	>=sys-libs/glibc-2.7
"
DEPEND="${COMMON_DEPEND}
	gnome-base/gnome-common

	$(vala_depend)
"

S="${WORKDIR}"

PATCHES=(
	"${FILESDIR}"/0002-productsearch.ubuntu.com-only-accepts-locale-string.patch
	"${FILESDIR}"/Remove-Software-center-and-1kB-filter-option-and-fix-100kB.patch
	"${FILESDIR}"/Do-not-retry-null-SmartScopesClient.patch
)

src_configure() {
	local myeconfargs=(
		$(use_enable test headless-tests)
	)
	econf "${myeconfargs[@]}"
}
