# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..13} )

UVER=+
UREV=0ubuntu11

inherit desktop gnome2 distutils-r1 ubuntu-versionator

DESCRIPTION="Configuration manager for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/unity-tweak-tool"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.debian.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="+bluetooth +files"
RESTRICT="test"

RDEPEND="
	gnome-base/dconf
	x11-misc/notify-osd
	>=unity-base/unity-6.8
	x11-libs/gtk+:3[introspection]

	bluetooth? ( unity-indicators/unity-indicators-meta[bluetooth] )
	files? ( unity-lenses/unity-lens-meta[files] )

	$(python_gen_cond_dep '
		dev-python/pycairo[${PYTHON_USEDEP}]
		dev-python/pyxdg[${PYTHON_USEDEP}]
	')
"
DEPEND="
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/python-distutils-extra[${PYTHON_USEDEP}]
	')
"

PATCHES=(
	# Include /usr/share/cursors/xorg-x11/ in the paths to check for cursor themes as Gentoo #
	#  installs cursor themes in both /usr/share/cursors/xorg-x11/ and /usr/share/icons/ #
	"${FILESDIR}"/xorg-cursor-themes-path.diff
)

src_prepare() {
	# Make Unity Tweak Tool appear in unity-control-center #
	sed -i \
		-e 's:Categories=.*:Categories=Settings;X-GNOME-Settings-Panel;X-GNOME-PersonalSettings;X-Unity-Settings-Panel;:' \
		-e 's: %f::' \
		-e '/Actions=/{:a;n;/^$/!ba;i\X-Unity-Settings-Panel=unitytweak' -e '}' \
		unity-tweak-tool.desktop.in || die

	# Fix Missing parentheses in call to 'print' #
	sed -i \
		-e "s/context.CurrentProfile.Name/(context.CurrentProfile.Name)/" \
		notes/wizardry.py || die

	# Disable recompiling GSettings schemas #
	sed -i "/compile_schemas(self/d" setup.py || die

	# Remove Apport support #
	rm debian/source_unity-tweak-tool.py || die

	use bluetooth || sed -i \
		-e "/indicator.bluetooth/d" \
		UnityTweakTool/section/spaghetti/gsettings.py || die

	use files || sed -i \
		-e "/FilesLens/d" \
		UnityTweakTool/section/spaghetti/gsettings.py || die

	ubuntu-versionator_src_prepare
}

src_install() {
	distutils-r1_src_install
	python_optimize

	# Fix /usr/share/applications path #
	local pysite="${ED}/$(python_get_sitedir)"
	newmenu "${pysite}"/usr/share/applications/extras-"${PN}".desktop \
		"${PN}".desktop
	rm -r "${pysite}"/usr || die

	exeinto /etc/X11/xinit/xinitrc.d
	doexe "${FILESDIR}/95-xcursor-theme"

	rm -r "${ED}/usr/share/doc/${PN}" || die
}
