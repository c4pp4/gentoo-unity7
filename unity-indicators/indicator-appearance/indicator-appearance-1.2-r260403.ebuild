# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{12..15} )

UVER=build1
UREV=
MY_PN="unity-${PN}"

inherit python-single-r1 xdg ubuntu-versionator

DESCRIPTION="Appearance indicator for the Unity desktop"
HOMEPAGE="https://unity.ubuntuunity.org"
SRC_URI="${UURL/${PN}/${MY_PN}}.tar.xz"
S="${WORKDIR}/${MY_PN}-${PV}${UVER}"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="amd64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RESTRICT="binchecks strip test"

RDEPEND="
	dev-libs/libappindicator:3
	gnome-base/gsettings-desktop-schemas
	x11-libs/gtk+:3[introspection]
	x11-themes/yaru-theme[unity]

	${PYTHON_DEPS}
	$(python_gen_cond_dep 'dev-python/pygobject:3[${PYTHON_USEDEP}]')
"

PATCHES=(
	"${FILESDIR}"/Add-more-accent-colors.patch
	"${FILESDIR}"/Add-translation-support.patch
	"${FILESDIR}"/Update-status-on-icon-theme-change.patch
	"${FILESDIR}"/Remove-unused-libnotify.patch
)

src_install() {
	default

	python_doscript "${MY_PN}"

	# If a .desktop file does not have inline #
	# translations, fall back to calling gettext #
	sed -i -e "\$a X-GNOME-Gettext-Domain=${PN}" autostart/"${MY_PN}".desktop || die
	grep -qx "X-GNOME-Gettext-Domain=${PN}" autostart/"${MY_PN}".desktop || die

	insinto /etc/xdg/autostart
	doins autostart/"${MY_PN}".desktop

	insinto /usr/share/icons/hicolor/scalable/apps
	doins icons/"${MY_PN}".svg

	insinto /usr/share
	doins -r "${FILESDIR}"/icons
}
