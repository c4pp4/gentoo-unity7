# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
GNOME2_EAUTORECONF="yes"
PYTHON_COMPAT=( python3_{8..10} )

UVER="+19.10.20190716"
UREV="0ubuntu3"

inherit gnome2 python-r1 ubuntu-versionator vala

DESCRIPTION="Keyboard indicator used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/indicator-keyboard"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+charmap +fcitx"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="gnome-base/gnome-desktop:3=
	charmap? ( gnome-extra/gucharmap:2.90 )
	${PYTHON_DEPS}"
DEPEND="${RDEPEND}
	app-i18n/ibus[vala]
	>=dev-libs/glib-2.37
	dev-libs/libappindicator
	dev-libs/libgee:0.8
	dev-libs/libdbusmenu
	gnome-base/dconf
	gnome-base/libgnomekbd
	sys-apps/accountsservice
	unity-base/bamf
	x11-libs/gtk+:3
	x11-libs/libxklavier
	x11-libs/pango
	x11-misc/lightdm

	fcitx? ( >=app-i18n/fcitx-4.2.8.5 )

	$(vala_depend)"

src_unpack() {
	mkdir "${P}"
	pushd "${P}" 1>/dev/null
		unpack ${A}
	popd 1>/dev/null
}

src_prepare() {
	eapply "${FILESDIR}/${PN}-fix-build-against-vala-0.52.patch"
	eapply "${FILESDIR}/${PN}-optional-fcitx.patch"

	use charmap || sed -i \
		-e "/Character Map/d" \
		lib/indicator-menu.vala

	# Fix "SyntaxError: Missing parentheses in call to 'print'" #
	sed -i \
		-e "s/print level \* ' ', root/print (level \* ' ', root)/" \
		tests/autopilot/tests/test_indicator_keyboard.py

	ubuntu-versionator_src_prepare
}

src_configure() {
	python_copy_sources
	configuration() {
		econf \
			$(use_enable fcitx)
	}
	python_foreach_impl run_in_build_dir configuration
}

src_compile() {
	compilation() {
		default
	}
	python_foreach_impl run_in_build_dir compilation
}

src_install() {
	installation() {
		default
	}
	python_foreach_impl run_in_build_dir installation
	python_foreach_impl python_optimize

	find "${ED}" -name '*.la' -delete || die
}
