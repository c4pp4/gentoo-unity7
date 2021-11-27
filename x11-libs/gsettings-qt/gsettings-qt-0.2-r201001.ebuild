# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

UVER=""
UREV="4"

inherit qmake-utils ubuntu-versionator

DESCRIPTION="Qml bindings for GSettings."
HOMEPAGE="https://launchpad.net/gsettings-qt"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.debian.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"

DEPEND="dev-libs/glib:2
	dev-qt/qtcore:5
	dev-qt/qtdeclarative:5
	test? ( dev-qt/qttest:5 )"

S="${WORKDIR}/${PN}-v${PV}"
unset QT_QPA_PLATFORMTHEME
MAKEOPTS="${MAKEOPTS} -j1"

src_prepare() {
	ubuntu-versionator_src_prepare

	# Don't pre-strip
	echo "CONFIG+=nostrip" >> "${S}"/GSettings/gsettings-qt.pro
	echo "CONFIG+=nostrip" >> "${S}"/src/gsettings-qt.pro
	echo "CONFIG+=nostrip" >> "${S}"/tests/tests.pro

	use test || sed -i \
		-e "s:\(GSettings/gsettings-qt.pro\) \\\:\1:" \
		-e "/tests.pro/d" \
		-e "/cpptest.pro/d" \
		"${S}"/gsettings-qt.pro
}

src_configure() {
	eqmake5
}

src_install () {
	emake INSTALL_ROOT="${ED}" install
}
