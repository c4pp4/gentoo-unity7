# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{8..10} )

UVER=""
UREV="4ubuntu1"

inherit autotools bash-completion-r1 python-r1 vala xdg ubuntu-versionator

DESCRIPTION="Service to log activities and present to other apps"
HOMEPAGE="https://launchpad.net/zeitgeist/"
SRC_URI="${UURL}.orig.tar.xz
	${UURL}-${UREV}.debian.tar.xz"

LICENSE="LGPL-2+ LGPL-3+ GPL-2+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+datahub +downloads-monitor +fts +icu introspection nls sql-debug telepathy"
REQUIRED_USE="${PYTHON_REQUIRED_USE}
	downloads-monitor? ( datahub )"

RDEPEND="${PYTHON_DEPS}
	dev-libs/json-glib
	dev-python/dbus-python[${PYTHON_USEDEP}]
	dev-python/rdflib[${PYTHON_USEDEP}]
	media-libs/raptor:2
	>=dev-libs/glib-2.35.4:2
	>=dev-db/sqlite-3.7.11:3
	sys-apps/dbus
	datahub? ( x11-libs/gtk+:3 )
	fts? ( dev-libs/xapian:0=[inmemory] )
	icu? ( dev-libs/dee[icu] )
	introspection? ( dev-libs/gobject-introspection )
	telepathy? ( net-libs/telepathy-glib )
"
DEPEND="${RDEPEND}
	$(vala_depend)
	>=sys-devel/automake-1.15:1.15
	>=sys-devel/gettext-0.19
	virtual/pkgconfig
"

PATCHES=(
	# As of vala 0.51.1, PtrArray is a subclass of GenericArray
	"${FILESDIR}"/0001-use-genericarray-api-only.patch
)

src_prepare() {
	# Fix pre_populator.patch
	sed -i \
		-e "s/+1,117/+1,119/" \
		-e "/thunderbird/r ${FILESDIR}/mail-clients" \
		-e "s/yelp/unity-yelp/" \
		"${WORKDIR}/debian/patches/pre_populator.patch" || die

	# pure-python module is better managed manually, see src_install
	sed -e 's:python::g' \
		-i Makefile.am || die

	ubuntu-versionator_src_prepare
	eautoreconf

	# XDG autostart only in Unity
	echo "OnlyShowIn=Unity;" >> data/zeitgeist-datahub.desktop.in
}

src_configure() {
	local myeconfargs=(
		--docdir="${EPREFIX}/usr/share/doc/${PF}"
		$(use_enable datahub)
		$(use_enable downloads-monitor)
		$(use_enable fts)
		$(use_with icu dee-icu)
		$(use_enable introspection)
		$(use_enable nls)
		$(use_enable sql-debug explain-queries)
		$(use_enable telepathy)
	)

	python_setup
	econf "${myeconfargs[@]}"
}

src_test() {
	emake check TESTS_ENVIRONMENT="dbus-run-session"
}

src_install() {
	default

	dobashcomp data/completions/zeitgeist-daemon

	cd python || die
	python_moduleinto ${PN}
	python_foreach_impl python_domodule *py

	# Redundant NEWS/AUTHOR installation
	rm -r "${D}"/usr/share/zeitgeist/doc/ || die

	# perform VACUUM SQLite database on startups every 10 days
	exeinto /usr/libexec/${PN}
	doexe "${WORKDIR}/debian/zeitgeist-maybe-vacuum"

	find "${ED}" -name '*.la' -delete || die
}
