# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..15} )

UVER=+17.10.20170605
UREV=0ubuntu10

inherit distutils-r1 ubuntu-versionator

DESCRIPTION="Photo lens for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/unity-lens-photos"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"
S="${WORKDIR}/${P}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="test"

RDEPEND="
	>=dev-libs/dee-1.2.5:0=[${PYTHON_SINGLE_USEDEP}]
	>=dev-libs/glib-2.80:2[introspection]
	>=dev-libs/libunity-7:0=[${PYTHON_SINGLE_USEDEP}]
	media-gfx/shotwell

	$(python_gen_cond_dep 'dev-python/pygobject:3[${PYTHON_USEDEP}]')
"
BDEPEND="
	$(python_gen_cond_dep '
		dev-python/python-distutils-extra[${PYTHON_USEDEP}]
	')
"

PATCHES=(
	"${FILESDIR}"/Fix-timestamp-NoneType-error.patch
	"${FILESDIR}"/remove-goa-scopes.diff
	"${FILESDIR}"/Show-photo-in-default-file-manager.patch
	"${FILESDIR}"/Fix-scope-crash.patch
	"${FILESDIR}"/Fix-preview-crash.patch
)

src_unpack() {
	# Keep distutils-r1 build directory inside WORKDIR #
	ubuntu-versionator_src_unpack
}

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
	grep -Fq "org.gnome.Shotwell.desktop" src/unity_shotwell_daemon.py || die

	# Don't install the scope daemon as a top-level Python module #
	sed -i \
		-e 's/setup(name="unity-lens-photos",/setup(name="unity-lens-photos", py_modules=[],/' \
		setup.py || die

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
