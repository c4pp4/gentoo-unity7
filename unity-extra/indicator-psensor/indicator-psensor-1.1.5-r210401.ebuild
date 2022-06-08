# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=1.3ubuntu2

inherit gnome2 ubuntu-versionator
MY_PN="psensor"
UURL="${UURL%/*}/${MY_PN}_${PV}${UVER}"

DESCRIPTION="Indicator for monitoring hardware temperature used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/psensor"
SRC_URI="${UURL}.orig.tar.gz
	${UURL}-${UREV}.debian.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="hddtemp nls"

COMMON_DEPEND="
	>=dev-libs/json-c-0.15
	>=dev-libs/libappindicator-0.2.92:3
	>=dev-libs/libatasmart-0.13
	>=dev-libs/libunity-3.4.6:0=
	>=gnome-base/libgtop-2.22.3:2=
	>=net-libs/libmicrohttpd-0.9.50
	>=net-misc/curl-7.16.2
	>=sys-apps/lm-sensors-3.5.0
	>=sys-fs/udisks-2.0.0:2
	>=x11-libs/gtk+-3.3.16:3
	>=x11-libs/libnotify-0.7.0
"
RDEPEND="${COMMON_DEPEND}
	>=dev-libs/glib-2.30.0:2
	gnome-base/dconf
	>=sys-libs/glibc-2.33
	>=x11-libs/cairo-1.2.4
	x11-libs/libX11

	hddtemp? ( app-admin/hddtemp )
"
DEPEND="${COMMON_DEPEND}
	app-text/asciidoc
	dev-util/cppcheck
	sys-apps/help2man
	sys-devel/gettext
"

S="${WORKDIR}/${MY_PN}-${PV}"

MAKEOPTS="${MAKEOPTS} -j1"

src_prepare() {
	# Revert dependency to deprecated appindicator #
	sed -i \
		-e "s/ayatana-appindicator/#ayatana-appindicator/" \
		"${WORKDIR}/debian/patches/series" || die

	# Fix error: this ‘if’ clause does not guard... [-Werror=misleading-indentation] #
	sed -i \
		-e "/data->last_smart_update = t;/{s/^\t\t/\t/}" \
		src/lib/pudisks2.c || die

	ubuntu-versionator_src_prepare
}

src_configure() {
	econf $(use_enable nls)
}
