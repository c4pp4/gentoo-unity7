# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{8..11} )
UBUNTU_EAUTORECONF="yes"

UVER=+17.10.20170616
UREV=7

inherit python-single-r1 vala ubuntu-versionator

DESCRIPTION="Provide objects allowing to create Model-View-Controller type programs across DBus"
HOMEPAGE="https://launchpad.net/dee/"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.debian.tar.xz"

LICENSE="GPL-3 LGPL-3"
SLOT="0/$(usub)"
KEYWORDS="~amd64"
IUSE="debug doc examples +icu test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RESTRICT="!test? ( test )"

COMMON_DEPEND="
	dev-libs/dbus-glib
	dev-libs/glib:2

	icu? ( dev-libs/icu:= )
"
RDEPEND="${COMMON_DEPEND}
	>=sys-libs/glibc-2.33

	doc? ( dev-util/devhelp )
"
DEPEND="${COMMON_DEPEND}
	dev-libs/gobject-introspection
	gnome-base/gnome-common
	sys-apps/dbus

	doc? ( 	dev-util/gtk-doc )
	test? ( dev-util/dbus-test-runner )

	${PYTHON_DEPS}
	$(python_gen_cond_dep 'dev-python/pygobject:3[${PYTHON_USEDEP}]')

	$(vala_depend)
"
BDEPEND="
	virtual/pkgconfig
"

S="${WORKDIR}"

src_configure() {
	local myeconfargs=(
		--disable-silent-rules
		$(use_enable debug trace-log)
		$(use_enable doc gtk-doc)
		$(use_enable icu)
		$(use_enable test tests)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default

	doman debian/"${PN}"-tool.1

	use examples && dodoc -r examples

	find "${ED}" -name '*.la' -delete || die
}
