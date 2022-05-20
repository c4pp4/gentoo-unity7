# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
UBUNTU_EAUTORECONF="yes"

UVER=+22.04.20220217
UREV=0ubuntu1

inherit ubuntu-versionator vala

DESCRIPTION="BAMF Application Matching Framework"
HOMEPAGE="https://launchpad.net/bamf"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3 LGPL-2.1 LGPL-3"
SLOT="0/1.0.0"
KEYWORDS="~amd64"
IUSE="doc"
RESTRICT="${RESTRICT} test"

COMMON_DEPEND="
	>=dev-libs/glib-2.43.2:2
	>=dev-libs/libdbusmenu-0.4.2[gtk3]
	>=gnome-base/libgtop-2.22.3:2
	>=x11-libs/libwnck-3.4.7:3
	>=x11-libs/gtk+-3.9.10:3[introspection]
"
RDEPEND="${COMMON_DEPEND}
	>=sys-libs/glibc-2.14
	>=x11-libs/gdk-pixbuf-2.22.0:2
	x11-libs/libX11
	>=x11-libs/startup-notification-0.11

	doc? ( dev-util/devhelp )
"
DEPEND="${COMMON_DEPEND}
	gnome-base/gnome-common
	>=sys-apps/dbus-1.8
	x11-themes/hicolor-icon-theme

	doc? ( dev-util/gtk-doc )

	$(vala_depend)
"

S="${WORKDIR}"

src_prepare() {
	#  'After=graphical-session-pre.target' must be explicitly set in the unit files that require it #
	#  Relying on the upstart job /usr/share/upstart/systemd-session/upstart/systemd-graphical-session.conf #
	#       to create "$XDG_RUNTIME_DIR/systemd/user/${unit}.d/graphical-session-pre.conf" drop-in units #
	#       results in weird race problems on desktop logout where the reliant desktop services #
	#       stop in a different jumbled order each time #
	sed -i \
		-e '/PartOf=/i After=graphical-session-pre.target' \
		data/bamfdaemon.service.in || die

	# Remove 'Restart=on-failure' and instead bind to unity7.service so as not to create false fail triggers for both services #
	sed -i \
		-e 's:Restart=on-failure::g' \
		-e '/PartOf=/a BindsTo=unity7.service' \
		data/bamfdaemon.service.in || die

	ubuntu-versionator_src_prepare
}

src_configure() {
	local myeconfargs=(
		--disable-static
		--enable-compile-warnings=maximum
		--enable-export-actions-menu=yes
		$(use_enable doc gtk-doc)
		--enable-headless-tests=no
		--enable-introspection=yes
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default

	# Install dbus interfaces #
	insinto /usr/share/dbus-1/interfaces
	doins lib/libbamf-private/org.ayatana.bamf.*xml

	# Install bamf-2.index creation script #
	#  Run at postinst of *.desktop files from ubuntu-versionator.eclass #
	#  bamf-index-create only indexes *.desktop files in /usr/share/applications #
	exeinto /usr/bin
	newexe debian/bamfdaemon.postinst bamf-index-create

	# Disable upstart session job when using systemd session service #
	dodir /usr/share/upstart/systemd-session/upstart
	echo manual > "${ED}"/usr/share/upstart/systemd-session/upstart/bamfdaemon.override

	find "${ED}" -name '*.la' -delete || die
}
