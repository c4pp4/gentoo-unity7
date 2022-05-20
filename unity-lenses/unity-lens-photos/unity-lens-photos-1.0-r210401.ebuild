# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{8..10} )

UVER=+17.10.20170605
UREV=0ubuntu9

inherit distutils-r1 ubuntu-versionator

DESCRIPTION="Photo lens for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/unity-lens-photos"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="gnome-online-accounts"
RESTRICT="${RESTRICT} test"

RDEPEND="
	>=dev-libs/dee-1.2.5:=[${PYTHON_SINGLE_USEDEP}]
	>=dev-libs/libunity-7:=[${PYTHON_SINGLE_USEDEP}]
	media-gfx/shotwell

	gnome-online-accounts? (
		dev-libs/libgdata[gnome-online-accounts,introspection]
		net-libs/libsoup:2.4[introspection]

		$(python_gen_cond_dep '
			dev-python/httplib2[${PYTHON_USEDEP}]
			dev-python/oauthlib[${PYTHON_USEDEP}]
			>=net-libs/libaccounts-glib-1.0:=[${PYTHON_USEDEP}]
			net-libs/libsignon-glib[introspection,${PYTHON_USEDEP}]
		')
	)
	${PYTHON_DEPS}
"
DEPEND="${PYTHON_DEPS}"

S="${WORKDIR}"

src_prepare() {
	# Remove Facebook, Flickr and Picasa scopes #
	#  as they are not maintained and tested anymore #
	use gnome-online-accounts || eapply "${FILESDIR}/remove-goa-scopes.diff"

	ubuntu-versionator_src_prepare
}

src_configure() {
	# Workaround for distutils-r1.eclass: install --skip-build #
	local mydistutilsargs=( build )
	distutils-r1_src_configure
}

src_install() {
	distutils-r1_src_install

	# Remove all installed language files as they can be incomplete #
	#  due to being provided by Ubuntu's language-pack packages #
	rm -rf "${ED}/usr/share/locale"

	python_fix_shebang "${ED}"
}

pkg_postinst() {
	ubuntu-versionator_pkg_postinst

	if use gnome-online-accounts; then
		echo
		ewarn "USE flag 'gnome-online-accounts' declared:"
		ewarn "Facebook, Flickr and Picasa scopes are installed but not maintained and tested anymore."
		echo
	fi
}
