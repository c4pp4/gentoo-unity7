# Copyright 1999-2021 Gentoo Foundation
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
			-e "s/d2369e87106064d4c4ff65a0e65dca11/0afc24559ae1018b9433d2ef48e35a14/" \
			"${files[@]}"

		files=( $(find ubuntu-help -maxdepth 2 -type f -name "*.po") )
		sed -i \
			-e ":bgn;/Unity⁷/{:loop;n;/^#/b bgn;s/Ubuntu/Gentoo Unity⁷/g;b loop;}" \
			"${files[@]}"

		cp "${FILESDIR}"/gentoo_signet.png ubuntu-help/C/figures/ubuntu-logo.png
		cp "${FILESDIR}"/unity_logo.png ubuntu-help/C/figures/ubuntu-mascot-creature.png
	fi

	ubuntu-versionator_src_prepare
}
