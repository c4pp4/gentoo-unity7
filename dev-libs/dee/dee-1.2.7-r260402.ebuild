# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{12..15} )
UBUNTU_EAUTORECONF="yes"

UVER=+17.10.20170616
UREV=8build1

inherit python-single-r1 vala ubuntu-versionator

DESCRIPTION="Objects for creating Model-View-Controller type programs across DBus"
HOMEPAGE="https://launchpad.net/dee/"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.debian.tar.xz"
S="${WORKDIR}"

LICENSE="GPL-3 LGPL-3"
SLOT="0/$(usub)"
KEYWORDS="amd64"
IUSE="debug doc examples test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RESTRICT="!test? ( test )"

COMMON_DEPEND="
	dev-libs/glib:2
	dev-libs/icu:=
"
RDEPEND="${COMMON_DEPEND}
	${PYTHON_DEPS}
	$(python_gen_cond_dep 'dev-python/pygobject:3[${PYTHON_USEDEP}]')
"
DEPEND="${COMMON_DEPEND}"
BDEPEND="
	dev-build/gtk-doc-am
	dev-libs/gobject-introspection
	virtual/pkgconfig

	doc? ( dev-util/gtk-doc )
	test? (
		dev-util/dbus-test-runner
		sys-apps/dbus
	)

	${PYTHON_DEPS}
	$(python_gen_cond_dep 'dev-python/pygobject:3[${PYTHON_USEDEP}]')

	$(vala_depend)
"

src_configure() {
	local myeconfargs=(
		--disable-silent-rules
		$(use_enable debug trace-log)
		$(use_enable doc gtk-doc)
		--enable-icu
		$(use_enable test tests)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default

	doman debian/"${PN}"-tool.1

	if use examples; then
		docinto examples
		dodoc examples/{list-peers,*.c,*.py,*.vala}
		docompress -x /usr/share/doc/${PF}/examples
	fi

	find "${ED}" -name '*.la' -delete || die
}
