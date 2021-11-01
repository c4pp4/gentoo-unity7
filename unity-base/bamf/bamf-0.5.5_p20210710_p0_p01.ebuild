# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{8..10} )

URELEASE="impish"
inherit autotools eutils python-single-r1 ubuntu-versionator vala xdummy

UVER_PREFIX="+${UVER_RELEASE}.${PVR_MICRO}"

DESCRIPTION="BAMF Application Matching Framework"
HOMEPAGE="https://launchpad.net/bamf"
SRC_URI="${UURL}/${MY_P}${UVER_PREFIX}.orig.tar.gz
	${UURL}/${MY_P}${UVER_PREFIX}-${UVER}.diff.gz"

LICENSE="LGPL-3"
SLOT="0/1.0.0"
KEYWORDS="~amd64"
IUSE="test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RESTRICT="mirror"

DEPEND="dev-libs/gobject-introspection
	dev-libs/libdbusmenu[gtk3]
	dev-util/gdbus-codegen
	gnome-base/libgtop
	x11-libs/gtk+:2
	x11-libs/gtk+:3
	x11-libs/libwnck:1
	x11-libs/libwnck:3
	x11-libs/libXfixes
	$(python_gen_cond_dep '
		dev-libs/libunity[${PYTHON_MULTI_USEDEP}]
		dev-libs/libxml2[${PYTHON_MULTI_USEDEP}]
		dev-python/lxml[${PYTHON_MULTI_USEDEP}]
	')
	${PYTHON_DEPS}
	$(vala_depend)"

S="${WORKDIR}"

pkg_setup() {
	ubuntu-versionator_pkg_setup
	python-single-r1_pkg_setup
}

src_prepare() {
	ubuntu-versionator_src_prepare

	#  'After=graphical-session-pre.target' must be explicitly set in the unit files that require it #
	#  Relying on the upstart job /usr/share/upstart/systemd-session/upstart/systemd-graphical-session.conf #
	#       to create "$XDG_RUNTIME_DIR/systemd/user/${unit}.d/graphical-session-pre.conf" drop-in units #
	#       results in weird race problems on desktop logout where the reliant desktop services #
	#       stop in a different jumbled order each time #
	sed -i \
		-e '/PartOf=/i After=graphical-session-pre.target' \
		data/bamfdaemon.service.in || die "Sed failed for data/bamfdaemon.service.in"

	# Remove 'Restart=on-failure' and instead bind to unity7.service so as not to create false fail triggers for both services #
	sed -i \
		-e 's:Restart=on-failure::g' \
		-e '/PartOf=/a BindsTo=unity7.service' \
		data/bamfdaemon.service.in || die "Sed failed for data/bamfdaemon.service.in"

	vala_src_prepare
	export VALA_API_GEN=$VAPIGEN
	python_fix_shebang .
	eautoreconf
}

src_configure() {
	econf \
		--enable-compile-warnings=maximum \
		--enable-export-actions-menu=yes \
		--enable-introspection=yes \
		--disable-static || die
}

src_test() {
	local XDUMMY_COMMAND="make check"
	xdummymake
}

src_install() {
	emake DESTDIR="${ED}" install || die

	# Install dbus interfaces #
	insinto /usr/share/dbus-1/interfaces
	doins lib/libbamf-private/org.ayatana.bamf.*xml

	# Install bamf-2.index creation script #
	#  Run at postinst of *.desktop files from ubuntu-versionator.eclass #
	#  bamf-index-create only indexes *.desktop files in /usr/share/applications #
	#    Why not also /usr/share/applications/kde4/ ?
	exeinto /usr/bin
	newexe debian/bamfdaemon.postinst bamf-index-create

	# Tell upstart not to start bamf as it will instead be started by systemd #
	dodir /usr/share/upstart/systemd-session/upstart
	echo manual > "${ED}"usr/share/upstart/systemd-session/upstart/bamfdaemon.override

	prune_libtool_files --modules
}
