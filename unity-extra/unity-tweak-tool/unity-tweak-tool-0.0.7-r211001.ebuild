# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{8..10} )

UVER="+"
UREV="0ubuntu9"

inherit distutils-r1 ubuntu-versionator xdg

DESCRIPTION="Configuration manager for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/unity-tweak-tool"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.debian.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+bluetooth +files nls"

RDEPEND="dev-libs/glib:2
	dev-python/pycairo[${PYTHON_USEDEP}]
	dev-python/pyxdg[${PYTHON_USEDEP}]
	dev-python/pygobject:3[${PYTHON_USEDEP}]
	dev-python/python-distutils-extra[${PYTHON_USEDEP}]
	x11-libs/gtk+:3"
DEPEND="${RDEPEND}
	dev-util/intltool
	gnome-base/gsettings-desktop-schemas
	gnome-extra/nemo
	sys-devel/gettext
	unity-base/compiz
	unity-base/hud
	unity-base/overlay-scrollbar
	unity-base/unity
	unity-base/unity-settings-daemon
	unity-indicators/indicator-datetime
	unity-indicators/indicator-power
	unity-indicators/indicator-session
	unity-indicators/indicator-sound
	unity-lenses/unity-lens-applications
	virtual/pkgconfig
	x11-misc/notify-osd

	bluetooth? ( unity-indicators/unity-indicators-meta[bluetooth] )
	files? ( unity-lenses/unity-lens-meta[files] )

	${PYTHON_DEPS}"

pkg_setup() {
	ubuntu-versionator_pkg_setup

	## Cherry picked from gnome2_environment_reset() in xdg-utils.eclass ##
	#  Sandbox violations occur when building outside of an Xsession and XDG_RUNTIME_DIR is not defined to be in the sandbox
	#    but build will fail with the following if XDG_CACHE_HOME is defined (see issue #125): 'ImportError: No module named 'values'
	export XDG_RUNTIME_DIR="${T}/run"
	mkdir -p "${XDG_RUNTIME_DIR}" || die
	# This directory needs to be owned by the user, and chmod 0700
	# http://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html
	chmod 0700 "${XDG_RUNTIME_DIR}" || die
	unset DBUS_SESSION_BUS_ADDRESS
}

src_prepare() {
	# Make Unity Tweak Tool appear in unity-control-center #
	sed -e 's:Categories=.*:Categories=Settings;X-GNOME-Settings-Panel;X-GNOME-PersonalSettings;X-Unity-Settings-Panel;:' \
		-e 's: %f::' \
		-e '/Actions=/{:a;n;/^$/!ba;i\X-Unity-Settings-Panel=unitytweak' -e '}' \
			-i unity-tweak-tool.desktop.in || die

	# Include /usr/share/cursors/xorg-x11/ in the paths to check for cursor themes as Gentoo #
	#  installs cursor themes in both /usr/share/cursors/xorg-x11/ and /usr/share/icons/ #
	eapply "${FILESDIR}/xorg-cursor-themes-path.diff"

	# Fix SyntaxWarning: "is not"/"is" with a literal #
	sed -i \
		-e "s/is not -1/!= -1/" \
		-e "s/is 48/== 48/" \
		UnityTweakTool/{__init__.py,section/spaghetti/theme.py}
	
	# Fix Missing parentheses in call to 'print' #
	sed -i \
		-e "s/context.CurrentProfile.Name/(context.CurrentProfile.Name)/" \
		notes/wizardry.py

	use bluetooth || sed -i \
		-e "/indicator.bluetooth/d" \
		UnityTweakTool/section/spaghetti/gsettings.py

	use files || sed -i \
		-e "/FilesLens/d" \
		UnityTweakTool/section/spaghetti/gsettings.py

	ubuntu-versionator_src_prepare

	# Fix antialiasing and hinting key names #
	sed -i \
		-e "s/'antialiasing'/'font-antialiasing'/" \
		-e "s/'hinting'/'font-hinting'/" \
		UnityTweakTool/section/{appearance.py,spaghetti/theme.py}
}

src_install() {
	distutils-r1_src_install

	exeinto /etc/X11/xinit/xinitrc.d
	doexe "${FILESDIR}/95-xcursor-theme"

	python_foreach_impl python_optimize

	rm -r "${ED%/}/usr/share/doc/${PN}"
}
