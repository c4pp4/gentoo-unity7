# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
GNOME2_EAUTORECONF="yes"

UVER=
UREV=0ubuntu5

inherit gnome2 ubuntu-versionator vala

DESCRIPTION="Graphical system load indicator for CPU, ram, etc. used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/indicator-multiload"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="test"

COMMON_DEPEND="
	>=dev-libs/libappindicator-0.3.91:3
	>=gnome-base/libgtop-2.22.3:2=
	>=x11-libs/cairo-1.2.4
	>=x11-libs/gtk+-3.3.16:3
"
RDEPEND="${COMMON_DEPEND}
	>=dev-libs/glib-2.41.1:2
	gnome-base/dconf
	gnome-extra/gnome-system-monitor
	>=sys-libs/glibc-2.14
"
DEPEND="${COMMON_DEPEND}
	gnome-base/gnome-common
	sys-devel/gettext

	$(vala_depend)
"

src_prepare() {
	ubuntu-versionator_src_prepare

	# Fix docdir #
	sed -i "/^multiloaddocdir =/{s/${PN}/${PF}/}" Makefile.in || die
}
