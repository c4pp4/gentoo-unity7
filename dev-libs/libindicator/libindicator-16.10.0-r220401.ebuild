# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
UBUNTU_EAUTORECONF="yes"

UVER=+18.04.20180321.1
UREV=0ubuntu5

inherit ubuntu-versionator

DESCRIPTION="A set of symbols and convenience functions that all indicators would like to use"
HOMEPAGE="https://launchpad.net/libindicator"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3"
SLOT="3/7.0.0"
KEYWORDS="~amd64"
IUSE="test"
RESTRICT="${RESTRICT} !test? ( test )"

COMMON_DEPEND="
	>=dev-libs/glib-2.37.3:2
	>=unity-indicators/ido-13.10.0
	>=x11-libs/gtk+-2.18:2
	>=x11-libs/gtk+-3.5.18:3
"
RDEPEND="${COMMON_DEPEND}
	>=sys-libs/glibc-2.4
	>=x11-libs/gdk-pixbuf-2.22.0:2
"
DEPEND="${COMMON_DEPEND}
	gnome-base/gnome-common

	test? (
		dev-util/dbus-test-runner
		x11-misc/xvfb-run
	)
"
BDEPEND="
	dev-util/intltool
	sys-devel/libtool
"

S="${WORKDIR}"

MAKEOPTS="${MAKEOPTS} -j1"

src_configure() {
	local myconfigureargs=(
		--disable-static
		--enable-debug
		--libdir=/usr/$(get_libdir)
		--prefix=/usr
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
		emake -C libindicator DESTDIR="${D}" install
		emake -C tools DESTDIR="${D}" install
	popd >/dev/null || die

	# Install GTK2 support #
	pushd build-gtk2 >/dev/null || die
		emake DESTDIR="${D}" install
	popd >/dev/null || die

	find "${ED}" -name '*.la' -delete || die
}
