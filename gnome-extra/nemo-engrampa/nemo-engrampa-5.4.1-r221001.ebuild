# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=+ds
UREV=1
MY_PN="nemo-fileroller"

inherit meson ubuntu-versionator

DESCRIPTION="Nemo engrampa integration"
HOMEPAGE="https://projects.linuxmint.com/cinnamon/ https://github.com/linuxmint/nemo-extensions"
SRC_URI="${UURL/${PN}/${MY_PN}}.orig.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="test"

COMMON_DEPEND="
	>=dev-libs/glib-2.14.0
	>=gnome-extra/nemo-2.0.0
"
RDEPEND="${COMMON_DEPEND}
	app-arch/engrampa
"
DEPEND="${COMMON_DEPEND}"

S="${WORKDIR}/${PN}"

src_unpack() {
	default
	mv "${MY_PN}" "${PN}"
}

src_prepare() {
	for f in "${S}"/src/*fileroller*; do
		mv "${f}" "${f/fileroller/engrampa}"
	done

	find -type f -exec sed -i -E \
		-e 's:FILEROLLER:ENGRAMPA:' \
		-e 's:file[\ \-]?roller:engrampa:g' \
		-e 's:File[\ \-]?[rR]oller:Engrampa:g' \
		{} \;

	ubuntu-versionator_src_prepare
}
