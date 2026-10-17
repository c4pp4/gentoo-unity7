# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
GNOME2_EAUTORECONF="yes"
GNOME2_LA_PUNT="yes"

UVER=+18.10.20180918
UREV=0ubuntu8

inherit gnome2 systemd ubuntu-versionator vala

DESCRIPTION="Indicator collecting messages that need a response for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/indicator-messages"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"
S="${WORKDIR}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="doc"
RESTRICT="test"

COMMON_DEPEND="
	>=dev-libs/glib-2.37.3:2
	>=sys-apps/accountsservice-0.6.8:=
"
RDEPEND="${COMMON_DEPEND}
	dev-libs/libindicator:3
	gnome-base/dconf
"
DEPEND="${COMMON_DEPEND}"
BDEPEND="
	dev-build/gtk-doc-am
	>=dev-libs/gobject-introspection-0.9.12
	dev-util/intltool
	gnome-base/gnome-common
	virtual/pkgconfig

	doc? ( dev-util/gtk-doc )

	$(vala_depend)
"

src_prepare() {
	# Don't try to find test dep #
	sed -i "/DBUSTEST/d" configure.ac || die

	# gtk-doc.make is normally copied by gtkdocize (dev-util/gtk-doc)
	if ! use doc; then
		echo "EXTRA_DIST =" > gtk-doc.make || die
	fi

	ubuntu-versionator_src_prepare

	# Install the systemd user unit even without sys-apps/systemd #
	sed -i \
		-e "s:^SYSTEMD_USERDIR=.*:SYSTEMD_USERDIR=$(systemd_get_userunitdir):" \
		configure || die
}

src_configure() {
	local mygnome2args=(
		$(use_enable doc gtk-doc)
	)
	gnome2_src_configure "${mygnome2args[@]}"
}
