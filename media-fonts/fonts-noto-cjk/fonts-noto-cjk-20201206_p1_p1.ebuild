# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
URELEASE="hirsute"
inherit font ubuntu-versionator

DESCRIPTION="No Tofu font families with large Unicode coverage"
HOMEPAGE="https://www.google.com/get/noto/ https://github.com/googlei18n/noto-cjk"

UVER_PREFIX="-cjk+repack${PVR_MICRO}"
UVER="-${PVR_PL_MAJOR}"
LSVER="0.211"
SRC_URI="${UURL}/${MY_P}${UVER_PREFIX}.orig.tar.xz
	${UURL}/${MY_P}${UVER_PREFIX}${UVER}.debian.tar.xz
	${UURL}/language-selector_${LSVER}.tar.xz"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64"
IUSE="extra"

RESTRICT="mirror binchecks strip"

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
	use extra || find "${WORKDIR}" -type f -name "*.ttc" \
		! -name "*CJK-Regular.ttc" \
		! -name "*CJK-Bold.ttc" \
			-delete

	mv "${WORKDIR}"/noto-cjk-20201206-cjk/* "${WORKDIR}"
	font_src_install

	local \
		f \
		symlink_dir="/etc/fonts/conf.d"

	einfo "Creating fontconfig configuration symlinks ..."
	dodir "${symlink_dir}"
	for f in "${ED}"/etc/fonts/conf.avail/*; do
		f=${f##*/}
		echo " * ${f}"
		dosym "../conf.avail/${f}" "${symlink_dir}/${f}"
	done

	dodoc debian/copyright
}
