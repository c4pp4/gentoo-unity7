# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..15} )

UVER=
UREV=3build1

inherit distutils-r1 xdg ubuntu-versionator

DESCRIPTION="An extensible mail notification daemon"
HOMEPAGE="https://github.com/pulb/mailnag"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.debian.tar.xz"

LICENSE="CC0-1.0 GPL-2+ PSF-2"
SLOT="0"
KEYWORDS="amd64"
IUSE="+messagingmenu"
RESTRICT="test"

RDEPEND="
	app-crypt/libsecret[introspection]
	dev-libs/glib:2[introspection]
	media-libs/gst-plugins-base:1.0[introspection,ogg,vorbis]
	media-libs/gstreamer:1.0[introspection]
	x11-libs/gtk+:3[introspection]
	>=x11-libs/libnotify-0.7[introspection]

	messagingmenu? ( x11-plugins/mailnag-messagingmenu-plugin )

	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/dbus-python[${PYTHON_USEDEP}]
		dev-python/pygobject:3[${PYTHON_USEDEP}]
		dev-python/pyxdg[${PYTHON_USEDEP}]
		dev-python/zombie-imp[${PYTHON_USEDEP}]
	')
"
BDEPEND="sys-devel/gettext"

PATCHES=(
	"${FILESDIR}"/handle-glib-exception-in-conntest.patch
	"${FILESDIR}"/fix-notification-icon.patch
)

src_prepare() {
	ubuntu-versionator_src_prepare

	# Rename metainfo to match the rdns ID set by 1010-appstream-metainfo-id-rdns.patch #
	mv data/mailnag.appdata.xml data/com.github.pulb.mailnag.metainfo.xml || die
	sed -i "s:data/mailnag.appdata.xml:data/com.github.pulb.mailnag.metainfo.xml:" setup.py || die

	echo "X-GNOME-Gettext-Domain=mailnag" >> data/mailnag-config.desktop || die
}

src_install() {
	distutils-r1_src_install

	doman data/"${PN}".1 data/"${PN}"-config.1
}
