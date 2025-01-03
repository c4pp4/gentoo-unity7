# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
UBUNTU_EAUTORECONF="yes"

UVER=+20.10.20200706.1
UREV=0ubuntu6

inherit multilib-minimal ubuntu-versionator vala

DESCRIPTION="A library to allow applications to export a menu into the Unity Menu bar"
HOMEPAGE="https://launchpad.net/libappindicator"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="LGPL-2.1 LGPL-3"
SLOT="3"
KEYWORDS="amd64"
IUSE="test"
RESTRICT="!test? ( test )"

COMMON_DEPEND="
	>=dev-libs/dbus-glib-0.82[${MULTILIB_USEDEP}]
	>=dev-libs/glib-2.35.4:2[${MULTILIB_USEDEP}]
	>=dev-libs/libdbusmenu-0.5.90:=[gtk3,${MULTILIB_USEDEP}]
	>=x11-libs/gtk+-3.0.0:3[introspection,${MULTILIB_USEDEP}]
"
RDEPEND="${COMMON_DEPEND}
	>=sys-libs/glibc-2.4
"
DEPEND="${COMMON_DEPEND}
	app-accessibility/at-spi2-core:2
	dev-libs/gobject-introspection
	dev-libs/libxml2:2[${MULTILIB_USEDEP}]
	gnome-base/gnome-common

	test? ( dev-util/dbus-test-runner )

	$(vala_depend)
"
BDEPEND="
	dev-util/gtk-doc
	dev-util/intltool
"

S="${WORKDIR}"

MAKEOPTS="${MAKEOPTS} -j1"

multilib_src_configure() {
	local myeconfargs=(
		$(use_enable test tests)
		--with-gtk=3
	)
	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
}

multilib_src_install_all() {
	default
	find "${ED}" -name '*.la' -delete || die
}
