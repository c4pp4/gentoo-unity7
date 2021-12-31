# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

UVER="+19.04.20190308.1"
UREV="0ubuntu3"

inherit autotools ubuntu-versionator

DESCRIPTION="Application indicators used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/indicator-application"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-libs/libappindicator:=
	dev-libs/libdbusmenu:="

S="${WORKDIR}"

src_prepare() {
	ubuntu-versionator_src_prepare
	# Fix desktop file installation location #
	sed 's:$(pkgdatadir)/upstart/xdg/autostart:$(datadir)/upstart/xdg/autostart:g' \
		-i data/upstart/Makefile.am
	eautoreconf

	# src/application-service-appstore.c uses 'app->status = APP_INDICATOR_STATUS_PASSIVE' to remove the app from panel #
	#	However some SNI tray icons always report their status as 'Passive' and so never show up, or get removed when they shouldn't be
	#	Examples are:
	#	KTorrent (never shows up)
	#	Quassel (disappears when disconnected from it's core)
	#	  Quassel also requires patching to have a complete base set of SNI items (profiles/ehooks/net-irc/quassel/files/SNI-systray_fix.patch)
	eapply "${FILESDIR}/sni-systray_show-passive_v2.diff"
}

src_install() {
	default
	find "${ED}" \( -name "*.a" -o -name "*.la" \) -delete || die
}
