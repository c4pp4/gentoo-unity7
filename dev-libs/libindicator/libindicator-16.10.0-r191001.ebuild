# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

UVER="+18.04.20180321.1"
UREV="0ubuntu4"

inherit autotools ubuntu-versionator

DESCRIPTION="A set of symbols and convenience functions that all indicators would like to use"
HOMEPAGE="https://launchpad.net/libindicator"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3"
SLOT="3/7.0.0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND=">=x11-libs/gtk+-2.18:2
	>=x11-libs/gtk+-3.2:3
	x11-libs/libXfixes"
DEPEND="${RDEPEND}
	>=dev-libs/glib-2.37
	>=unity-indicators/ido-13.10.0
	virtual/pkgconfig
	!<${CATEGORY}/${PN}-0.4.1-r201"

S="${WORKDIR}"
MAKEOPTS="${MAKEOPTS} -j1"

src_prepare() {
	ubuntu-versionator_src_prepare
	eautoreconf
}

src_configure() {
	# Build GTK2 support #
	[[ -d build-gtk2 ]] || mkdir build-gtk2
	pushd build-gtk2
		../configure --prefix=/usr \
			--libdir=/usr/$(get_libdir) \
			--enable-debug \
			--disable-static \
			--with-gtk=2 || die
	popd

	# Build GTK3 support #
	[[ -d build-gtk3 ]] || mkdir build-gtk3
	pushd build-gtk3
		../configure --prefix=/usr \
			--libdir=/usr/$(get_libdir) \
			--enable-debug \
			--disable-static \
			--with-gtk=3 || die
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
		emake -C libindicator DESTDIR="${D}" install || die
		emake -C tools DESTDIR="${D}" install || die
	popd

	einstalldocs
	find "${ED}" -name '*.la' -delete || die
}