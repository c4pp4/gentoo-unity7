# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{8..10} )

UVER=""
UREV="0ubuntu3"

inherit gnome2 distutils-r1 ubuntu-versionator

DESCRIPTION="CPU frequency scaling indicator for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/classicmenu-indicator"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.debian.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

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
	# Allow users to use the indicator #
	sed -i 's:auth_admin_keep:yes:' indicator_cpufreq/com.ubuntu.indicatorcpufreq.policy.in

	ubuntu-versionator_src_prepare
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
