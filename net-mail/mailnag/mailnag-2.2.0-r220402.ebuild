# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{8..10} )

UVER=
UREV=1

inherit distutils-r1 xdg ubuntu-versionator

DESCRIPTION="An extensible mail notification daemon"
HOMEPAGE="https://github.com/pulb/mailnag"

LICENSE="CC0-1.0 GPL-2+ PSF-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+messagingmenu"
RESTRICT="${RESTRICT} test"

COMMON_DEPEND="
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/dbus-python[${PYTHON_USEDEP}]
		dev-python/pyxdg[${PYTHON_USEDEP}]
	')
"
RDEPEND="${COMMON_DEPEND}
	app-crypt/libsecret[introspection]
	dev-libs/gobject-introspection
	media-libs/gst-plugins-base:1.0[introspection]
	x11-libs/gtk+:3[introspection]
	>=x11-libs/libnotify-0.7[introspection]

	messagingmenu? ( x11-plugins/mailnag-messagingmenu-plugin )

	$(python_gen_cond_dep 'dev-python/pygobject:3[${PYTHON_USEDEP}]')
"
DEPEND="${COMMON_DEPEND}"
BDEPEND="sys-devel/gettext"

PATCHES=(
	"${FILESDIR}"/handle-glib-exception-in-conntest.patch
	"${FILESDIR}"/set-ssl-ciphers-for-python-3.10.patch
)

src_install() {
	distutils-r1_src_install

	echo "X-GNOME-Gettext-Domain=mailnag" \
		>> "${ED}"/usr/share/applications/"${PN}"-config.desktop || die

	doman data/"${PN}".1
	doman data/"${PN}"-config.1
}
