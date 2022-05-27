# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{8..10} )
UBUNTU_EAUTORECONF="yes"

UVER=+19.04.20190319
UREV=6build1

inherit python-single-r1 vala ubuntu-versionator

DESCRIPTION="Library for instrumenting and integrating with all aspects of the Unity shell"
HOMEPAGE="https://launchpad.net/libunity"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3 LGPL-3"
SLOT="0/9.0.2"
KEYWORDS="~amd64"
IUSE="test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RESTRICT="${RESTRICT} !test? ( test )"

COMMON_DEPEND="
	>=dev-libs/dee-1.2.7:0=[${PYTHON_SINGLE_USEDEP}]
	>=dev-libs/glib-2.43.92:2
	>=dev-libs/libdbusmenu-0.4.90[introspection]
"
RDEPEND="${COMMON_DEPEND}
	gnome-base/dconf
	>=sys-libs/glibc-2.4
"
DEPEND="${COMMON_DEPEND}
	gnome-base/gnome-common
	sys-apps/dbus[X]
	x11-apps/xauth

	test? ( x11-misc/xvfb-run )

	${PYTHON_DEPS}
	$(python_gen_cond_dep 'dev-python/pygobject:3[${PYTHON_USEDEP}]')

	$(vala_depend)
"
BDEPEND="
	dev-util/intltool
	virtual/pkgconfig
"

S="${WORKDIR}"

src_configure() {
	econf $(use_enable test headless-tests)
}

src_install() {
	default
	find "${ED}" \( -name "*.a" -o -name "*.la" \) -delete || die
}
