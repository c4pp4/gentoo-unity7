# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
FONT_PN="ubuntu"

UVER=+git20240321
UREV=0ubuntu2

inherit font ubuntu-versionator

DESCRIPTION="The Ubuntu variable font with adjustable weight and width axes."
HOMEPAGE="https://design.ubuntu.com/font/"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.debian.tar.xz"

LICENSE="UbuntuFontLicense-1.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="extra"
RESTRICT="binchecks strip test"

RDEPEND="!media-fonts/ubuntu-font-family"

S="${S}${UVER}"

FONT_SUFFIX="ttf"
FONT_CONF=( "${WORKDIR}"/debian/71-ubuntulegacy.conf )

src_install() {
	# Fix FONTDIR #
	sed -i "s:/truetype::g" "${FONT_CONF}"

	# Add ubuntu legacy names #
	local line
	while read -r line; do
		[[ ${line} == "usr/share/fonts"* ]] \
			&& ln -s ${line//usr\/share\/fonts\/truetype\/ubuntu\/}
	done < "${WORKDIR}"/debian/fonts-ubuntu.links

	font_src_install

	local f="${FONT_CONF##*/}"
	einfo "Creating fontconfig configuration symlink ..."
	echo " * ${f}"
	dosym -r /etc/fonts/conf.avail/"${f}" /etc/fonts/conf.d/"${f}"

	# Console fonts #
	if use extra; then
		insinto /usr/share/consolefonts
		doins "${WORKDIR}"/debian/console/UbuntuMono-*.psf
		newins "${WORKDIR}"/debian/console/README README.Ubuntu
	fi
}
