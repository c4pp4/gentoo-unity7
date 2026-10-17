# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_EXT=1
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..15} )

UVER=+ds
UREV=1ubuntu1

inherit gnome2 distutils-r1 udev ubuntu-versionator

DESCRIPTION="Simple on-screen Keyboard with macros and easy layout creation"
HOMEPAGE="https://launchpad.net/onboard"
SRC_URI="${UURL}.orig.tar.xz ${UURL}-${UREV}.debian.tar.xz"
S="${S}${UVER}"

LICENSE="CC-BY-4.0 GPL-3+ BSD"
SLOT="0"
KEYWORDS="amd64"
IUSE="+accessibility gnome-shell wayland"
RESTRICT="test"

COMMON_DEPEND="
	>=app-text/hunspell-1.7
	app-text/iso-codes
	>=gnome-base/dconf-0.14.0
	gnome-base/gsettings-desktop-schemas
	>=media-libs/libcanberra-0.2
	virtual/libudev:=
	>=x11-libs/gtk+-3.9.10:3[introspection]
	>=x11-libs/libxkbfile-1.1.0
	x11-libs/libXtst

	wayland? (
		dev-libs/wayland
		x11-libs/gtk+:3[wayland]
		x11-libs/libxkbcommon
	)

	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/dbus-python[${PYTHON_USEDEP}]
		dev-python/pycairo[${PYTHON_USEDEP}]
		dev-python/pygobject:3[${PYTHON_USEDEP}]
	')
"
RDEPEND="${COMMON_DEPEND}
	>=dev-libs/glib-2.31.8:2
	dev-libs/libayatana-appindicator
	gnome-base/librsvg
	>=x11-libs/cairo-1.10.0
	x11-libs/gdk-pixbuf:2[introspection]
	x11-libs/libX11
	>=x11-libs/libXi-1.2.99.4
	>=x11-libs/pango-1.29.3[introspection]

	accessibility? ( >=app-accessibility/at-spi2-core-2.46.0:2 )
	wayland? ( gui-libs/gtk-layer-shell[introspection] )
"
DEPEND="${COMMON_DEPEND}"
BDEPEND="
	dev-libs/glib:2
	dev-util/intltool
	sys-devel/gettext
	virtual/pkgconfig

	$(python_gen_cond_dep '
		dev-python/python-distutils-extra[${PYTHON_USEDEP}]
	')
"

src_prepare() {
	# Drop stray top-level module, it would be installed into site-packages #
	rm settings_ui.py || die

	# Fix doc dir #
	sed -i "s:share/doc/${PN}:share/doc/${PF}:" setup.py || die

	ubuntu-versionator_src_prepare
}

src_install() {
	distutils-r1_src_install

	# Fix /etc/xdg/autostart path (wheels can't install outside prefix) #
	mv "${D}$(python_get_sitedir)"/etc "${ED}" || die

	# Drop README* duplicates auto-installed by DistUtilsExtra (already in ${PF}) #
	rm -r "${ED}"/usr/share/doc/"${PN}" || die

	# Drop package-contains-compiled-glib-schema
	rm "${ED}"/usr/share/glib-2.0/schemas/gschemas.compiled || die

	# Drop gnome-shell-extension-onboard files
	if ! use gnome-shell; then
		rm -r "${ED}"/usr/share/gnome-shell || die
		rm -r "${ED}"/usr/share/onboard/gnome-extension || die
		rm "${ED}"/usr/share/glib-2.0/schemas/org.gnome.shell.extensions.onboard-indicator.gschema.xml || die
	fi

	# Install udev rule granting uinput access for key injection on Wayland #
	use wayland && udev_dorules "${ED}"/usr/share/onboard/72-onboard-uinput.rules
	rm "${ED}"/usr/share/onboard/72-onboard-uinput.rules || die
}

pkg_postinst() {
	ubuntu-versionator_pkg_postinst
	use wayland && udev_reload
}

pkg_postrm() {
	gnome2_pkg_postrm
	use wayland && udev_reload
}
