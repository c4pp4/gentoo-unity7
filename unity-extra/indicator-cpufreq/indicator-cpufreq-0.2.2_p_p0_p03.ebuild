# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{7..9} )

URELEASE="hirsute"
inherit distutils-r1 gnome2-utils ubuntu-versionator xdg-utils

DESCRIPTION="CPU frequency scaling indicator for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/classicmenu-indicator"
SRC_URI="${UURL}/${PN}_${PV}.orig.tar.gz
	${UURL}/${PN}_${PV}-${UVER}.debian.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="mirror"

RDEPEND="dev-libs/glib:2
	dev-libs/libappindicator
	dev-python/dbus-python[${PYTHON_USEDEP}]
	dev-python/pygobject:3[${PYTHON_USEDEP}]
	sys-power/cpufrequtils
	x11-libs/gtk+:3"
DEPEND="${RDEPEND}
	dev-util/intltool
	sys-devel/gettext
	virtual/pkgconfig
	${PYTHON_DEPS}"

src_prepare() {
	ubuntu-versionator_src_prepare
	# Allow users to use the indicator #
	sed -e 's:auth_admin_keep:yes:' \
		-i indicator_cpufreq/com.ubuntu.indicatorcpufreq.policy.in
	distutils-r1_src_prepare
}

src_install() {
	distutils-r1_src_install

	insinto /var/lib/polkit-1/localauthority/50-local.d
	doins "${WORKDIR}/debian/indicator-cpufreq.pkla"

	doman "${WORKDIR}/debian/indicator-cpufreq.1"
	doman "${WORKDIR}/debian/indicator-cpufreq-selector.1"

	insinto /etc/xdg/autostart
	doins "${ED}usr/share/applications/indicator-cpufreq.desktop"
}

pkg_postinst() {
	xdg_icon_cache_update
	ubuntu-versionator_pkg_postinst
}

pkg_postrm() { xdg_icon_cache_update; }
