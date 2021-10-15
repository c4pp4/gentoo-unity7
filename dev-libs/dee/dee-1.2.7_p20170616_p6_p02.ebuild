# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{7..9} )
AUTOTOOLS_AUTORECONF=y

URELEASE="impish"
inherit autotools eutils python-r1 ubuntu-versionator vala

UVER_PREFIX="+17.10.${PVR_MICRO}"

DESCRIPTION="Provide objects allowing to create Model-View-Controller type programs across DBus"
HOMEPAGE="https://launchpad.net/dee/"
SRC_URI="${UURL}/${MY_P}${UVER_PREFIX}.orig.tar.gz
	${UURL}/${MY_P}${UVER_PREFIX}-${UVER}.debian.tar.xz"

SLOT="0/4.2.1"
LICENSE="GPL-3"
KEYWORDS="~amd64"
IUSE="doc debug examples +icu static-libs test"
RESTRICT="mirror"

RDEPEND="dev-libs/glib:2
	dev-libs/icu:="
DEPEND="${RDEPEND}
	dev-util/gtk-doc
	test? ( dev-util/dbus-test-runner )
	${PYTHON_DEPS}
	$(vala_depend)"

S="${WORKDIR}"

src_prepare() {
	ubuntu-versionator_src_prepare
	vala_src_prepare
	eautoreconf
}

src_configure() {
	local myeconfargs=(
		--disable-silent-rules
		$(use_enable debug trace-log)
		$(use_enable doc gtk-doc)
		$(use_enable icu)
		$(use_enable test tests)
		)
	econf
}

src_install() {
	emake DESTDIR="${ED}" install

	if use examples; then
		insinto /usr/share/doc/${PN}/
		doins -r examples
	fi

	find "${ED}" -type f -name '*.la' -delete || die
}
