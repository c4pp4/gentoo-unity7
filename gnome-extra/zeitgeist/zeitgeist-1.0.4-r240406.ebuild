# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{10..14} )
UBUNTU_EAUTORECONF="yes"

UVER=
UREV=5ubuntu5

inherit python-single-r1 xdg ubuntu-versionator vala

DESCRIPTION="Service to log activities and present to other apps"
HOMEPAGE="https://launchpad.net/zeitgeist/"
SRC_URI="${UURL}.orig.tar.bz2
	${UURL}-${UREV}.debian.tar.xz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="amd64"
IUSE="+datahub doc +downloads-monitor +fts +icu introspection nls sql-debug telepathy test"
REQUIRED_USE="${PYTHON_REQUIRED_USE} downloads-monitor? ( datahub )"
RESTRICT="!test? ( test )"

COMMON_DEPEND="
	>=dev-db/sqlite-3.7.11:3
	>=dev-libs/glib-2.43.92:2
	>=dev-libs/json-glib-1.5.2

	datahub? ( >=x11-libs/gtk+-3.0.0:3 )
	fts? ( >=dev-libs/xapian-1.4.17:0=[inmemory(+)] )
	icu? ( >=dev-libs/dee-1.0.2:0=[icu,${PYTHON_SINGLE_USEDEP}] )
	introspection? ( >=dev-libs/gobject-introspection-1.30.0 )
	telepathy? ( >=net-libs/telepathy-glib-0.18.0 )

	${PYTHON_DEPS}
	$(python_gen_cond_dep 'dev-python/pygobject:3[${PYTHON_USEDEP}]')
"
RDEPEND="${COMMON_DEPEND}
	>=sys-devel/gcc-5.2
	>=sys-libs/glibc-2.14

	doc? ( dev-util/devhelp )

	$(python_gen_cond_dep '
		dev-python/dbus-python[${PYTHON_USEDEP}]
		dev-python/pyxdg[${PYTHON_USEDEP}]
	')
"
DEPEND="${COMMON_DEPEND}

	doc? (
		dev-lang/vala[valadoc]
		dev-util/gtk-doc
		media-libs/raptor:2
	)

	$(python_gen_cond_dep 'dev-python/rdflib[${PYTHON_USEDEP}]')

	$(vala_depend)
"

S="${WORKDIR}/${PN}-v${PV}"

src_prepare() {
	use doc && local VALA_USE_DEPEND="valadoc"

	# Fix pre_populator.patch #
	sed -i \
		-e "s/+1,117/+1,124/" \
		-e "/rhythmbox/r ${FILESDIR}/music-clients" \
		-e '/Calculator/a +    arr.add (event_for_desktop_file ("mate-calc.desktop", ++ts));' \
		-e '/gedit/a +    arr.add (event_for_desktop_file ("pluma.desktop", ++ts));' \
		-e '/Totem/a +    arr.add (event_for_desktop_file ("vlc.desktop", ++ts));' \
		-e "/thunderbird/r ${FILESDIR}/mail-clients" \
		-e "s/rhythmbox/org.gnome.Rhythmbox3/" \
		-e "s/yelp/unity-yelp/" \
		"${WORKDIR}/debian/patches/pre_populator.patch" || die

	# Fix doc dir #
	sed -i "s:pkgdatadir)/doc:datadir)/doc/${PF}:" Makefile.am || die

	ubuntu-versionator_src_prepare

	# XDG autostart only in Unity #
	echo "OnlyShowIn=Unity;" >> data/zeitgeist-datahub.desktop.in || die
}

src_configure() {
	local myeconfargs=(
		$(use_enable doc docs)
		$(use_enable datahub)
		$(use_enable downloads-monitor)
		$(use_enable fts)
		$(use_enable introspection)
		$(use_enable nls)
		$(use_enable sql-debug explain-queries)
		$(use_enable telepathy)
		$(use_with icu dee-icu)
	)
	econf "${myeconfargs[@]}"

	# Process translations #
	pushd po >/dev/null || die
		emake update-gmo || die
	popd >/dev/null || die
}

src_install() {
	default

	# Perform VACUUM SQLite database on startups every 10 days #
	exeinto /usr/libexec/"${PN}"
	doexe "${WORKDIR}"/debian/zeitgeist-maybe-vacuum

	# valadoc generated documentation #
	use doc && dodoc -r doc/libzeitgeist/docs_c doc/libzeitgeist/docs_vala

	find "${ED}" -name '*.la' -delete || die
}

pkg_postinst() {
	ubuntu-versionator_pkg_postinst

	echo
	elog "In case of problems, reset ZeitGeist database:"
	elog "rm -rfv ~/.local/share/zeitgeist"
	echo
}
