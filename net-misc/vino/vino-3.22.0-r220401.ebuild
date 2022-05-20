# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
GNOME2_EAUTORECONF="yes"

UVER=
UREV=6ubuntu3

inherit gnome2 systemd ubuntu-versionator

DESCRIPTION="An integrated VNC server for GNOME"
HOMEPAGE="https://wiki.gnome.org/Projects/Vino"
SRC_URI="${UURL}.orig.tar.xz
	${UURL}-${UREV}.debian.tar.xz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="crypt debug gnome-keyring ipv6 jpeg ssl +telepathy zeroconf +zlib"
REQUIRED_USE="jpeg? ( zlib )"
RESTRICT="${RESTRICT} test"

COMMON_DEPEND="
	>=dev-libs/glib-2.37.3:2
	>=net-libs/miniupnpc-1.9.20140610
	>=x11-libs/gtk+-3.0.0:3
	>=x11-libs/libICE-1.0.0
	>=x11-libs/libnotify-0.7.0
	x11-libs/libSM
	x11-libs/libX11
	>=x11-libs/libXdamage-1.1
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXtst

	crypt? ( >=dev-libs/libgcrypt-1.8.0:0= )
	gnome-keyring? ( >=app-crypt/libsecret-0.7 )
	jpeg? ( virtual/jpeg:0= )
	ssl? ( >=net-libs/gnutls-3.6.14:= )
	telepathy? (
		dev-libs/dbus-glib
		>=net-libs/telepathy-glib-0.18
	)
	zeroconf? ( >=net-dns/avahi-0.6.16:=[dbus] )
	zlib? ( >=sys-libs/zlib-1.1.4:= )
"
RDEPEND="${COMMON_DEPEND}
	gnome-base/dconf
	>=sys-libs/glibc-2.15
	>=x11-libs/cairo-1.10.0:=
	x11-libs/pango[X]
"
DEPEND="${COMMON_DEPEND}
	gnome-base/gnome-common
	x11-libs/libXt
"
BDEPEND="
	>=dev-util/intltool-0.50.0
	virtual/pkgconfig
"

src_configure() {
	gnome2_src_configure \
		$(use_enable ipv6) \
		$(use_with crypt gcrypt) \
		$(usex debug --enable-debug=yes ' ') \
		$(use_with gnome-keyring secret) \
		$(use_with jpeg) \
		$(use_with ssl gnutls) \
		$(use_with telepathy) \
		$(use_with zeroconf avahi) \
		$(use_with zlib) \
		--with-systemduserunitdir="$(systemd_get_userunitdir)"
}
