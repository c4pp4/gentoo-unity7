# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{12..15} )
UBUNTU_EAUTORECONF="yes"

UVER=+16.04.20160126
UREV=0ubuntu14

inherit python-single-r1 ubuntu-versionator

DESCRIPTION="An implementation of the GEIS (Gesture Engine Interface and Support) interface"
HOMEPAGE="https://launchpad.net/geis"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"
S="${S}${UVER}"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="doc"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

COMMON_DEPEND="
	>=sys-apps/dbus-1.9.14
	>=unity-base/frame-2.2.4
	>=unity-base/grail-3.0.8
	>=x11-libs/libX11-1.2.99.901
	>=x11-libs/libxcb-1.6
	x11-libs/libXext
	>=x11-libs/libXi-1.5.99.2

	${PYTHON_DEPS}
"
RDEPEND="${COMMON_DEPEND}
	x11-libs/gtk+:3[introspection]

	$(python_gen_cond_dep 'dev-python/pygobject:3[${PYTHON_USEDEP}]')
"
DEPEND="${COMMON_DEPEND}"
BDEPEND="
	virtual/pkgconfig

	doc? ( app-text/doxygen )
"

src_prepare() {
	if ! use doc; then
		sed -i ":api/html:,+1 d" doc/Makefile.am || die
	fi

	# Ensure GTK 3 is loaded when multiple versions are installed #
	sed -i \
		-e '/^import argparse$/i import gi\ngi.require_version("Gtk", "3.0")' \
		tools/geisview/geisview || die
	grep -Fqx 'gi.require_version("Gtk", "3.0")' tools/geisview/geisview || die

	ubuntu-versionator_src_prepare
}

src_compile() {
	default
	use doc && emake doc-html
}

src_install() {
	default

	python_fix_shebang "${ED}"/usr/bin

	find "${ED}" -name '*.la' -delete || die
}
