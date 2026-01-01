# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
FONT_PN="noto"

UVER=+repack1
UREV=1build1

inherit font ubuntu-versionator

DESCRIPTION="'No Tofu' CJK font families with large Unicode coverage (CJK regular and bold)"
HOMEPAGE="https://github.com/notofonts/noto-cjk"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.debian.tar.xz"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64"
IUSE="extra"
RESTRICT="binchecks strip test"

RDEPEND="!media-fonts/noto-cjk"

S="${WORKDIR}/tmp03n08f3k"

FONT_SUFFIX="ttc"
FONT_S=(
	"${S}/Sans/OTC"
	"${S}/Serif/OTC"
)
FONT_CONF=( "${WORKDIR}"/debian/70-"${PN}".conf )

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
