# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=+repack1
UREV=1
LSVER="0.219"

inherit font ubuntu-versionator

DESCRIPTION=" No Tofu CJK font families with large Unicode coverage"
HOMEPAGE="https://github.com/googlei18n/noto-cjk"

SRC_URI="${UURL}.orig.tar.xz
	${UURL}-${UREV}.debian.tar.xz
	${UURL%/*}/language-selector_${LSVER}.tar.xz"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="amd64"
IUSE="extra"
RESTRICT="binchecks strip test"

RDEPEND="!media-fonts/noto-cjk"

S="${WORKDIR}"

FONT_S="${S}"
FONT_SUFFIX="ttc"
FONT_CONF=(
	"${WORKDIR}"/debian/70-"${PN}".conf
	"${WORKDIR}"/language-selector/fontconfig/30-cjk-aliases.conf
	"${WORKDIR}"/language-selector/fontconfig/56-language-selector-ar.conf
	"${WORKDIR}"/language-selector/fontconfig/64-language-selector-prefer.conf
	"${WORKDIR}"/language-selector/fontconfig/69-language-selector-ja.conf
	"${WORKDIR}"/language-selector/fontconfig/69-language-selector-zh-cn.conf
	"${WORKDIR}"/language-selector/fontconfig/69-language-selector-zh-hk.conf
	"${WORKDIR}"/language-selector/fontconfig/69-language-selector-zh-mo.conf
	"${WORKDIR}"/language-selector/fontconfig/69-language-selector-zh-sg.conf
	"${WORKDIR}"/language-selector/fontconfig/69-language-selector-zh-tw.conf
	"${WORKDIR}"/language-selector/fontconfig/99-language-selector-zh.conf
)

src_install() {
	default

	use extra || find "${WORKDIR}" -type f -name "*.ttc" \
		! -name "*CJK-Regular.ttc" \
		! -name "*CJK-Bold.ttc" \
			-delete

	mv "${WORKDIR}"/"${PN/fonts-}"/{Sans,Serif}/OTC/* "${WORKDIR}"
	font_src_install

	local \
		symlink_dir="/etc/fonts/conf.d" \
		f

	einfo "Creating fontconfig configuration symlinks ..."
	dodir "${symlink_dir}"
	for f in "${ED}"/etc/fonts/conf.avail/*; do
		f=${f##*/}
		echo " * ${f}"
		dosym -r "/etc/fonts/conf.avail/${f}" "${symlink_dir}/${f}"
	done
}
