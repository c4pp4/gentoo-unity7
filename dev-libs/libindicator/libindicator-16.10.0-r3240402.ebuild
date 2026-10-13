# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
UBUNTU_EAUTORECONF="yes"

UVER=+18.04.20180321.1
UREV=0ubuntu8

inherit multilib-minimal ubuntu-versionator virtualx

DESCRIPTION="A set of symbols and convenience functions that all indicators would like to use"
HOMEPAGE="https://launchpad.net/libindicator"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"
S="${WORKDIR}"

LICENSE="GPL-3"
SLOT="3"
KEYWORDS="amd64"
IUSE="test"
RESTRICT="!test? ( test )"

COMMON_DEPEND="
	>=dev-libs/glib-2.37.3:2[${MULTILIB_USEDEP}]
	>=x11-libs/gdk-pixbuf-2.22.0:2[${MULTILIB_USEDEP}]
	>=dev-libs/ido-13.10.0:0=[${MULTILIB_USEDEP}]
	>=x11-libs/gtk+-3.5.18:3[${MULTILIB_USEDEP}]
"
RDEPEND="${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND}"
BDEPEND="
	dev-build/libtool
	dev-util/intltool
	virtual/pkgconfig

	test? ( dev-util/dbus-test-runner )
"

MAKEOPTS="${MAKEOPTS} -j1"

src_prepare() {
	# Fix typo #
	sed -i "/AM_SILENT_RULES/{s/]$//}" configure.ac || die

	# Skip test failing with GLib >= 2.80 (Weak notify timeout in g_test_dbus_down) #
	sed -i "/^TESTS += test-indicator-ng$/d" tests/Makefile.am || die

	ubuntu-versionator_src_prepare
}

multilib_src_configure() {
	local myeconfargs=(
		$(use_enable test tests)
		--with-gtk=3
	)
	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
}

multilib_src_test() {
	# b.g.o #391179
	virtx emake check
}

multilib_src_install_all() {
	default
	find "${ED}" -name '*.la' -delete || die

	# Drop test-only libraries #
	rm -f \
		"${ED}"/usr/lib*/libdummy-indicator-* \
		"${ED}"/usr/share/${PN}/*indicator-debugging \
		|| die
	find "${ED}" -type d -empty -delete || die
}
