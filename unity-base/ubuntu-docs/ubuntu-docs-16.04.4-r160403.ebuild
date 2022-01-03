# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
GNOME2_EAUTORECONF="yes"

UVER=""
UREV=""

inherit gnome2 ubuntu-versionator

DESCRIPTION="Help files for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/ubuntu-docs"
SRC_URI="${UURL}.tar.xz"

LICENSE="CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+branding"
RESTRICT="${RESTRICT} binchecks strip"

DEPEND="app-text/gnome-doc-utils
	app-text/yelp-tools
	dev-libs/libxml2
	gnome-extra/yelp"

src_prepare() {
	if use branding; then
		local -a files=( $(find ubuntu-help -maxdepth 2 -type f -name "*.po" -o -name "*.page") )

		sed -i \
			-e "s/Ubuntu Desktop/Gentoo Unity⁷ Desktop/" \
			-e "s/Ubuntu desktop/Gentoo Unity⁷ Desktop/" \
			-e "s/Welcome to Ubuntu/Welcome to Gentoo Unity⁷/" \
			-e "s/Ubuntu features/Gentoo Unity⁷ features/" \
			-e "s/Ubuntu Button/Gentoo Button/" \
			-e "s/the Ubuntu logo/the Gentoo logo/" \
			"${files[@]}"

		files=( $(find ubuntu-help -maxdepth 2 -type f -name "*.po") )
		sed -i ":bgn;/Unity⁷/{:loop;n;/^#/b bgn;s/Ubuntu/Gentoo Unity⁷/g;b loop;}" "${files[@]}"
		sed -i ":bgn;/Gentoo Button/{:loop;n;/^#/b bgn;s/Ubuntu/Gentoo/g;b loop;}" "${files[@]}"
		sed -i ":bgn;/the Gentoo logo/{:loop;n;/^#/b bgn;s/Ubuntu/Gentoo/g;b loop;}" "${files[@]}"

		sed -i "s/ addremove//" ubuntu-help/C/index.page
		sed -i "/Install languages/d" ubuntu-help/C/prefs-language.page
		sed -i '/id="complex"/,+49 d' ubuntu-help/C/keyboard-layouts.page
		sed -i "/dozens of languages/,+3 d" ubuntu-help/C/session-language.page
		sed -i "/language-selector/d" ubuntu-help/C/session-{formats,language}.page
		sed -i "/prefs-language-install.page/d" ubuntu-help/Makefile.am

		cp "${FILESDIR}"/gentoo_signet.png ubuntu-help/C/figures/ubuntu-logo.png
		cp "${FILESDIR}"/unity_logo.png ubuntu-help/C/figures/ubuntu-mascot-creature.png
		cp "${FILESDIR}"/unity.png ubuntu-help/C/figures
		cp "${FILESDIR}"/unity-dash.png ubuntu-help/C/figures
		cp "${FILESDIR}"/unity-dash-intro.png ubuntu-help/C/figures
		cp "${FILESDIR}"/unity-dash-sample.png ubuntu-help/C/figures
		cp "${FILESDIR}"/unity-launcher.png ubuntu-help/C/figures
		cp "${FILESDIR}"/unity-launcher-intro.png ubuntu-help/C/figures
		cp "${FILESDIR}"/unity-overview.png ubuntu-help/C/figures

		rm ubuntu-help/it/figures/unity.png
		rm ubuntu-help/{de,it}/figures/unity-dash.png
		rm ubuntu-help/it/figures/unity-dash-intro.png
		rm ubuntu-help/{de,it}/figures/unity-dash-sample.png
		rm ubuntu-help/{de,it}/figures/unity-launcher-intro.png
		rm ubuntu-help/{de,it}/figures/unity-overview.png
	fi

	ubuntu-versionator_src_prepare
}
