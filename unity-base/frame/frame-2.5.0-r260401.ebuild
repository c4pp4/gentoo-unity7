# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
UBUNTU_EAUTORECONF="yes"

UVER=daily13.06.05+16.10.20160809
UREV=0ubuntu5

inherit ubuntu-versionator

DESCRIPTION="Touch Frame Library"
HOMEPAGE="https://launchpad.net/frame"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"
S="${WORKDIR}"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="doc test"
RESTRICT="!test? ( test )"

COMMON_DEPEND="
	>=x11-libs/libX11-1.2.99.901
	>=x11-libs/libXi-1.5.99.2
"
RDEPEND="${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND}
	x11-base/xorg-proto
	x11-base/xorg-server
	x11-libs/libXext

	test? ( dev-cpp/gtest )
"
BDEPEND="
	app-text/asciidoc
	app-text/docbook-xsl-stylesheets
	dev-libs/libxslt
	virtual/pkgconfig

	doc? ( app-text/doxygen )
"

src_prepare() {
	if ! use doc; then
		sed -i ":api/html:,+1 d" doc/Makefile.am || die
	fi

	ubuntu-versionator_src_prepare
}

src_configure() {
	local myeconfargs=(
		--enable-integration-tests=no
		$(use_with test gtest-source-path /usr/src/gtest)
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
