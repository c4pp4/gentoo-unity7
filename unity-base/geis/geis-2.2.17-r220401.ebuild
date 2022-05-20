# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{8..10} )
UBUNTU_EAUTORECONF="yes"

UVER=+16.04.20160126
UREV=0ubuntu8

inherit python-single-r1 ubuntu-versionator

DESCRIPTION="An implementation of the GEIS (Gesture Engine Interface and Support) interface"
HOMEPAGE="https://launchpad.net/geis"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

COMMON_DEPEND="
	${PYTHON_DEPS}
	>=sys-apps/dbus-1.9.14
	>=unity-base/grail-3.0.8
	>=x11-libs/libX11-1.2.99.901
	>=x11-libs/libxcb-1.6
	>=x11-libs/libXi-1.5.99.2
"
RDEPEND="${COMMON_DEPEND}
	>=sys-libs/glibc-2.15
	>=unity-base/frame-2.2.4
	x11-libs/libXext
"
DEPEND="${COMMON_DEPEND}
	>=dev-libs/libxslt-1.1.19
	>=x11-base/xorg-server-1.10.1

	$(python_gen_cond_dep 'x11-base/xcb-proto[${PYTHON_USEDEP}]')
"
BDEPEND="
	virtual/pkgconfig

	doc? ( app-doc/doxygen )
"

S="${S}${UVER}"

src_prepare() {
	use doc || sed -i ":api/html:,+1 d" doc/Makefile.am || die
	ubuntu-versionator_src_prepare
}

src_compile() {
	default
	use doc && emake doc-html
}

src_install() {
	default
	find "${ED}" \( -name "*.a" -o -name "*.la" \) -delete || die
}
