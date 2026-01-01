# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..14} )

UVER=+17.10.20170605
UREV=0ubuntu9

inherit distutils-r1 ubuntu-versionator

DESCRIPTION="Photo lens for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/unity-lens-photos"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="test"

RDEPEND="
	>=dev-libs/dee-1.2.5:0=[${PYTHON_SINGLE_USEDEP}]
	>=dev-libs/libunity-7:0=[${PYTHON_SINGLE_USEDEP}]
	media-gfx/shotwell
"
DEPEND="
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/python-distutils-extra[${PYTHON_USEDEP}]
	')
"

S="${WORKDIR}"

PATCHES=(
	"${FILESDIR}"/Fix-timestamp-NoneType-error.patch
	"${FILESDIR}"/remove-goa-scopes.diff
)

src_prepare() {
	# Facebook, Flickr and Picasa scopes #
	# are not maintained and tested anymore #
	find -type f \
		\( -name '*facebook*' \
		-o -name '*flickr*' \
		-o -name '*picasa*' \) \
			-delete || die

	# Fix .desktop file name #
	sed -i \
		-e "s/shotwell\.desktop/org.gnome.Shotwell.desktop/" \
		src/unity_shotwell_daemon.py || die

	python_fix_shebang src/unity_shotwell_daemon.py

	ubuntu-versionator_src_prepare
}

src_install() {
	distutils-r1_src_install
	python_optimize

	# Remove all installed language files as they can be incomplete #
	#  due to being provided by Ubuntu's language-pack packages #
	rm -rf "${ED}/usr/share/locale"
}
