# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Utility to change the LightDM greeter being used"
HOMEPAGE="https://www.gentoo.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="binchecks strip test"

RDEPEND="app-admin/eselect"

S="${FILESDIR}"

src_install() {
	insinto /usr/share/eselect/modules
	newins "${FILESDIR}"/"${P}".eselect lightdm.eselect
}
