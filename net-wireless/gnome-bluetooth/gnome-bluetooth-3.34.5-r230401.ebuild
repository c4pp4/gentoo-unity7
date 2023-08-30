# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{10..12} )

UVER=
UREV=10

inherit gnome.org meson python-single-r1 udev xdg ubuntu-versionator

DESCRIPTION="Bluetooth graphical utilities integrated with GNOME"
HOMEPAGE="https://wiki.gnome.org/Projects/GnomeBluetooth"
SRC_URI="${UURL}.orig.tar.xz
	${UURL}-${UREV}.debian.tar.xz"

LICENSE="GPL-2+ LGPL-2.1+ FDL-1.1+"
SLOT="2/$(usub)"
KEYWORDS="amd64"
IUSE="gtk-doc +introspection test"
REQUIRED_USE="test? ( ${PYTHON_REQUIRED_USE} )"
RESTRICT="!test? ( test )"

COMMON_DEPEND="
	>=dev-libs/glib-2.59.0:2
	>=media-libs/libcanberra-0.25[gtk3]
	>=virtual/libudev-196
	>=x11-libs/gtk+-3.19.12:3[introspection?]
	>=x11-libs/libnotify-0.7.0
"
RDEPEND="${COMMON_DEPEND}
	>=app-accessibility/at-spi2-core-1.12.4:2
	>=sys-libs/glibc-2.29
	virtual/udev
"
DEPEND="${COMMON_DEPEND}
	dev-libs/libxml2:2

	gtk-doc? ( dev-util/gtk-doc )
	introspection? ( >=dev-libs/gobject-introspection-0.9.5 )
	test? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep '
			dev-python/dbus-python[${PYTHON_USEDEP}]
			dev-python/pygobject:3[${PYTHON_USEDEP}]
			dev-python/python-dbusmock[${PYTHON_USEDEP}]
		')
	)
"

pkg_setup() {
	use test && python-single-r1_pkg_setup
}

src_configure() {
	local emesonargs=(
		-Dicon_update=false
		$(meson_use gtk-doc gtk_doc)
		$(meson_use introspection)
	)
	meson_src_configure
}

src_install() {
	meson_src_install
	udev_dorules "${FILESDIR}"/61-${PN}.rules
}

pkg_postinst() {
	udev_reload
	ubuntu-versionator_pkg_postinst
	if ! has_version 'sys-apps/systemd[acl]' ; then
		elog "Don't forget to add yourself to the plugdev group "
		elog "if you want to be able to control bluetooth transmitter."
	fi
}

pkg_postrm() {
	udev_reload
}
