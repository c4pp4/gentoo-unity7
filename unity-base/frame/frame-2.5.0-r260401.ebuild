# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
UBUNTU_EAUTORECONF="yes"

UVER=daily13.06.05+16.10.20160809
UREV=0ubuntu5

inherit ubuntu-versionator

DESCRIPTION="Touch Frame Library"
HOMEPAGE="https://launchpad.net/frame"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc test"
RESTRICT="!test? ( test )"

COMMON_DEPEND="
	>=x11-libs/libX11-1.2.99.901
	>=x11-libs/libXi-1.5.99.2
"
RDEPEND="${COMMON_DEPEND}
	>=sys-devel/gcc-5
	>=sys-libs/glibc-2.15
"
DEPEND="${COMMON_DEPEND}
	app-text/asciidoc
	app-text/docbook-xsl-stylesheets
	dev-libs/libxslt
	x11-base/xorg-server

	test? ( dev-cpp/gtest )
"
BDEPEND="
	virtual/pkgconfig

	doc? ( app-doc/doxygen )
"

S="${WORKDIR}"

src_prepare() {
	use doc || sed -i ":api/html:,+1 d" doc/Makefile.am || die
	ubuntu-versionator_src_prepare
}

src_configure() {
	local myeconfargs=(
		--enable-integration-tests=no
		$(use_with test gtest-source-path)
	)
	econf "${myeconfargs[@]}"
}

src_compile() {
	default
	use doc && emake doc-html
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
