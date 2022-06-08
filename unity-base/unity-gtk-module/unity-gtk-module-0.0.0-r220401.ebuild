# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
UBUNTU_EAUTORECONF="yes"

UVER=+18.04.20171202
UREV=0ubuntu3

inherit ubuntu-versionator

DESCRIPTION="GTK+ module for exporting old-style menus as GMenuModels"
HOMEPAGE="https://launchpad.net/unity-gtk-module"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc"
RESTRICT="test"

COMMON_DEPEND="
	>=x11-libs/gtk+-2.24.0:2
	>=x11-libs/gtk+-3.3.16:3
	x11-libs/libX11
"
RDEPEND="${COMMON_DEPEND}
	>=dev-libs/glib-2.41.1:2
	gnome-base/dconf
	>=sys-libs/glibc-2.4
	>=x11-libs/gdk-pixbuf-2.22.0:2
"
DEPEND="${COMMON_DEPEND}
	doc? ( dev-util/gtk-doc )
"

S="${WORKDIR}"

src_prepare() {
	# Disable autopilot tests #
	sed -i "s/ tests//" Makefile.am || die

	ubuntu-versionator_src_prepare
}

src_configure() {
	local myconfigureargs=(
		--disable-static
		$(use_enable doc gtk-doc)
		--libdir=/usr/$(get_libdir)
		--prefix=/usr
		--sysconfdir=/etc
	)

	# Configure GTK3 support #
	printf "\n%s\n" " * Configuring GTK3 ..."
	[[ -d build-gtk3 ]] || mkdir build-gtk3 || die
	pushd build-gtk3 >/dev/null || die
		"${S}"/configure "${myconfigureargs[@]}"
	popd >/dev/null || die

	# Configure GTK2 support #
	printf "\n%s\n" " * Configuring GTK2 ..."
	[[ -d build-gtk2 ]] || mkdir build-gtk2 || die
	pushd build-gtk2 >/dev/null || die
		myconfigureargs+=( --with-gtk=2 )
		"${S}"/configure "${myconfigureargs[@]}"
	popd >/dev/null || die
}

src_compile() {
	# Build GTK3 support #
	printf "\n%s\n" " * Compiling GTK3 ..."
	pushd build-gtk3 >/dev/null || die
		default
	popd >/dev/null || die

	# Build GTK2 support #
	printf "\n%s\n" " * Compiling GTK2 ..."
	pushd build-gtk2 >/dev/null || die
		default
	popd >/dev/null || die
}

src_install() {
	default

	# Install GTK3 support #
	pushd build-gtk3 >/dev/null || die
		emake DESTDIR="${D}" install
	popd >/dev/null || die

	# Install GTK2 support #
	pushd build-gtk2 >/dev/null || die
		emake DESTDIR="${D}" install
	popd >/dev/null || die

	# Append module to GTK_MODULES environment variable #
	exeinto /etc/X11/xinit/xinitrc.d/
	doexe "${FILESDIR}/81unity-gtk-module"

	find "${ED}" -name '*.la' -delete || die
}
