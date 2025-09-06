# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=

inherit meson xdg ubuntu-versionator gnome.org vala

DESCRIPTION="GNOME framework for accessing online accounts"
HOMEPAGE="https://wiki.gnome.org/Projects/GnomeOnlineAccounts"

LICENSE="LGPL-2+"
SLOT="0/1"
KEYWORDS="amd64"
IUSE="gtk-doc kerberos vala"
RESTRICT="test"

COMMON_DEPEND="
	>=app-crypt/libsecret-0.7
	>=dev-libs/glib-2.75.3:2
	>=dev-libs/json-glib-1.5.2
	>=net-libs/libsoup-3.0.3:3.0
	>=net-libs/rest-0.9.1:1.0
	>=net-libs/webkit-gtk-2.33.1:4.1
	>=x11-libs/gtk+-3.19.12:3

	kerberos? (
		>=app-crypt/gcr-3.8.0:0=[gtk]
		>=app-crypt/mit-krb5-1.10
	)
"
RDEPEND="${COMMON_DEPEND}
	>=dev-libs/libxml2-2.9.0:2
	gnome-base/dconf
	>=sys-libs/glibc-2.4
"
DEPEND="${COMMON_DEPEND}
	>=dev-libs/gobject-introspection-0.9.3

	gtk-doc? ( dev-util/gtk-doc )
	vala? ( $(vala_depend) )
"

src_configure() {
	local emesonargs=(
		-Dgoabackend=true
		-Dinspector=false
		-Dexchange=true
		-Dfedora=false
		-Dgoogle=true
		-Dimap_smtp=true
		$(meson_use kerberos)
		-Dlastfm=true
		-Dmedia_server=true
		-Downcloud=true
		-Dwindows_live=true
		$(meson_use gtk-doc gtk_doc)
		-Dintrospection=true
		-Dman=true
		$(meson_use vala vapi)
	)
	meson_src_configure
}
