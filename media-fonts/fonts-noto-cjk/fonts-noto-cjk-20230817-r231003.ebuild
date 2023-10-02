# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
FONT_PN="noto"

UVER=+repack1
UREV=3
LSVER="0.224"

inherit font ubuntu-versionator

DESCRIPTION="'No Tofu' CJK font families with large Unicode coverage"
HOMEPAGE="https://github.com/notofonts/noto-cjk"
SRC_URI="${UURL}.orig.tar.xz
	${UURL}-${UREV}.debian.tar.xz
	${UURL%/*}/language-selector_${LSVER}.tar.xz"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64"
IUSE="extra"
RESTRICT="binchecks strip test"

RDEPEND="!media-fonts/noto-cjk"

S="${WORKDIR}/noto-cjk"

FONT_SUFFIX="ttc"
FONT_S=(
	"${S}/Sans/OTC"
	"${S}/Serif/OTC"
)
FONT_CONF=(
	"${WORKDIR}"/language-selector/fontconfig/30-cjk-aliases.conf
	"${WORKDIR}"/language-selector/fontconfig/56-language-selector-prefer.conf
	"${WORKDIR}"/language-selector/fontconfig/64-language-selector-cjk-prefer.conf
	"${WORKDIR}"/language-selector/fontconfig/69-language-selector-ja.conf
	"${WORKDIR}"/language-selector/fontconfig/69-language-selector-zh-cn.conf
	"${WORKDIR}"/language-selector/fontconfig/69-language-selector-zh-hk.conf
	"${WORKDIR}"/language-selector/fontconfig/69-language-selector-zh-mo.conf
	"${WORKDIR}"/language-selector/fontconfig/69-language-selector-zh-sg.conf
	"${WORKDIR}"/language-selector/fontconfig/69-language-selector-zh-tw.conf
	"${WORKDIR}"/debian/70-"${PN}".conf
	"${WORKDIR}"/language-selector/fontconfig/99-language-selector-zh.conf
)

src_install() {
	if use extra; then
		FONT_S+=(
			"${S}/Sans/Variable/OTC"
			"${S}/Serif/Variable/OTC"
		)
	else
		find "${WORKDIR}" -type f -name "*.ttc" \
			! -name "*CJK-Regular.ttc" \
			! -name "*CJK-Bold.ttc" \
				-delete || die
	fi

	font_src_install

	einfo "Creating fontconfig configuration symlinks ..."
	local f
	for f in "${ED}"/etc/fonts/conf.avail/*; do
		f=${f##*/}
		echo " * ${f}"
		dosym -r /etc/fonts/conf.avail/"${f}" /etc/fonts/conf.d/"${f}"
	done
}
