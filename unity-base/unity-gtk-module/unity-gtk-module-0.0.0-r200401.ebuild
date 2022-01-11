# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{8..10} )
UBUNTU_EAUTORECONF="yes"

UVER="+18.04.20171202"
UREV="0ubuntu2"

inherit python-r1 ubuntu-versionator

DESCRIPTION="GTK+ module for exporting old-style menus as GMenuModels"
HOMEPAGE="https://launchpad.net/unity-gtk-module"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="dev-libs/glib:2
	dev-libs/libdbusmenu:=[gtk3]
	x11-libs/libX11
	x11-libs/gtk+:2
	x11-libs/gtk+:3
	!x11-misc/appmenu-gtk
	${PYTHON_DEPS}"

S="${WORKDIR}"

src_prepare() {
	# Fix "SyntaxError: Missing parentheses in call to 'print'" #
	sed -i \
		-e "s/print level \* ' ', root/print (level \* ' ', root)/" \
		tests/autopilot/tests/test_gedit.py

	ubuntu-versionator_src_prepare
}

src_configure() {
	# Build GTK2 support #
	[[ -d build-gtk2 ]] || mkdir build-gtk2
	pushd build-gtk2
		../configure --prefix=/usr \
			--libdir=/usr/$(get_libdir) \
			--sysconfdir=/etc \
			--disable-static \
			--with-gtk=2 || die
	popd

	# Build GTK3 support #
	[[ -d build-gtk3 ]] || mkdir build-gtk3
	pushd build-gtk3
		../configure --prefix=/usr \
		--libdir=/usr/$(get_libdir) \
		--sysconfdir=/etc \
		--disable-static || die
	popd
}

src_compile() {
	# Build GTK2 support #
	pushd build-gtk2
		default
	popd

	# Build GTK3 support #
	pushd build-gtk3
		default
	popd
}

src_install() {
	# Install GTK2 support #
	pushd build-gtk2
		default
	popd

	# Install GTK3 support #
	pushd build-gtk3
		default
	popd

	# Append module to GTK_MODULES environment variable #
	exeinto /etc/X11/xinit/xinitrc.d/
	doexe "${FILESDIR}/81unity-gtk-module"

	python_foreach_impl python_optimize

	einstalldocs
	find "${ED}" -name '*.la' -delete || die
}
