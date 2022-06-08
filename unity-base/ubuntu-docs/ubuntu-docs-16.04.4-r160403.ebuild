# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
GNOME2_EAUTORECONF="yes"

UVER=
UREV=

inherit gnome2 ubuntu-versionator

DESCRIPTION="Help files for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/ubuntu-docs"
SRC_URI="${UURL}.tar.xz"

LICENSE="CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+branding"
RESTRICT="binchecks strip test"

RDEPEND="gnome-extra/yelp"
BDEPEND="
	app-text/yelp-tools
	gnome-base/gnome-common
	virtual/pkgconfig
"

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
			"${files[@]}" || die

		files=( $(find ubuntu-help -maxdepth 2 -type f -name "*.po") )
		sed -i ":bgn;/Unity⁷/{:loop;n;/^#/b bgn;s/Ubuntu/Gentoo Unity⁷/g;b loop;}" "${files[@]}" || die
		sed -i ":bgn;/Gentoo Button/{:loop;n;/^#/b bgn;s/Ubuntu/Gentoo/g;b loop;}" "${files[@]}" || die
		sed -i ":bgn;/the Gentoo logo/{:loop;n;/^#/b bgn;s/Ubuntu/Gentoo/g;b loop;}" "${files[@]}" || die

		pushd ubuntu-help/C >/dev/null || die
			sed -i "s/ addremove//" index.page || die
			sed -i "/Install languages/d" prefs-language.page || die
			sed -i '/id="complex"/,+49 d' keyboard-layouts.page || die
			sed -i "/dozens of languages/,+3 d" session-language.page || die
			sed -i "/language-selector/d" session-{formats,language}.page || die
		popd >/dev/null || die

		pushd ubuntu-help/C/figures >/dev/null || die
			cp "${FILESDIR}"/gentoo_signet.png ubuntu-logo.png || die
			cp "${FILESDIR}"/unity_logo.png ubuntu-mascot-creature.png || die
			cp "${FILESDIR}"/unity.png . || die
			cp "${FILESDIR}"/unity-dash.png . || die
			cp "${FILESDIR}"/unity-dash-intro.png . || die
			cp "${FILESDIR}"/unity-dash-sample.png . || die
			cp "${FILESDIR}"/unity-launcher.png . || die
			cp "${FILESDIR}"/unity-launcher-intro.png . || die
			cp "${FILESDIR}"/unity-overview.png . || die
		popd >/dev/null || die

		pushd ubuntu-help >/dev/null || die
			sed -i "/prefs-language-install.page/d" Makefile.am || die

			rm it/figures/unity.png || die
			rm {de,it}/figures/unity-dash.png || die
			rm it/figures/unity-dash-intro.png || die
			rm {de,it}/figures/unity-dash-sample.png || die
			rm {de,it}/figures/unity-launcher-intro.png || die
			rm {de,it}/figures/unity-overview.png || die
		popd >/dev/null || die
	fi

	ubuntu-versionator_src_prepare
}
