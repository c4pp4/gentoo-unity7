# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{8..10} )
UBUNTU_EAUTORECONF="yes"

UVER="+17.10.20170616"
UREV="6ubuntu3"

inherit python-single-r1 vala ubuntu-versionator

DESCRIPTION="Provide objects allowing to create Model-View-Controller type programs across DBus"
HOMEPAGE="https://launchpad.net/dee/"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.debian.tar.xz"

SLOT="0/4.2.1"
LICENSE="GPL-3"
#KEYWORDS="~amd64"
IUSE="debug doc examples +icu test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	dev-libs/glib:2
	icu? (
		dev-libs/icu:=
	)
"
DEPEND="${RDEPEND}
	gnome-base/gnome-common
	$(python_gen_cond_dep '
		dev-python/pygobject[${PYTHON_USEDEP}]
	')
	${PYTHON_DEPS}
"
BDEPEND="$(vala_depend)
	doc? (
		dev-util/gtk-doc
	)
	test? (
		dev-util/dbus-test-runner
	)
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

	if use examples; then
		insinto /usr/share/doc/${PN}/
		doins -r examples
	fi

	find "${ED}" -name '*.la' -delete || die
}
