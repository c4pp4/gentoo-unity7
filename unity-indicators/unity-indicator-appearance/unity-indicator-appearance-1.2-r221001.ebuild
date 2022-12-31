# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{8..11} )

UVER=
UREV=

inherit python-single-r1 xdg ubuntu-versionator

DESCRIPTION="Default settings for Ubuntu Unity"
HOMEPAGE="https://unity.ubuntuunity.org"
SRC_URI="${UURL}.tar.xz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="amd64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RESTRICT="binchecks strip test"

RDEPEND="
	dev-libs/libappindicator:3
	x11-libs/gtk+:3
	x11-libs/libnotify
	x11-themes/yaru-theme[unity]

	${PYTHON_DEPS}
	$(python_gen_cond_dep 'dev-python/pygobject:3[${PYTHON_USEDEP}]')
"

S="${WORKDIR}/${PN}"

src_install() {
	default

	exeinto /usr/bin
	doexe "${PN}"

	insinto /etc/xdg/autostart
	doins autostart/"${PN}".desktop

	insinto /usr/share/icons/hicolor/scalable/apps
	doins icons/"${PN}".svg
}
