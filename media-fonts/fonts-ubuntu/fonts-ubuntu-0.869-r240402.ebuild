# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
FONT_PN="ubuntu"

UVER=+git20240321
UREV=0ubuntu1

inherit font gnome2-utils ubuntu-versionator

DESCRIPTION="The Ubuntu variable font with adjustable weight and width axes."
HOMEPAGE="https://design.ubuntu.com/font/"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.debian.tar.xz"

LICENSE="UbuntuFontLicense-1.0"
SLOT="0"
KEYWORDS="amd64"
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

	# Override ubuntu-font-family monospace settings #
	insinto /usr/share/glib-2.0/schemas
	newins "${FILESDIR}"/"${PN}".gsettings-override 11_"${PN}".gschema.override

	# Console fonts #
	if use extra; then
		insinto /usr/share/consolefonts
		doins "${WORKDIR}"/debian/console/UbuntuMono-*.psf
		newins "${WORKDIR}"/debian/console/README README.Ubuntu
	fi
}

pkg_preinst() {
	# Modified gnome2_schemas_savelist to find *.gschema.override files #
	export GNOME2_ECLASS_GLIB_SCHEMAS=$(find "${ED}/usr/share/glib-2.0/schemas" -name "*.gschema.override" 2>/dev/null)
}

pkg_postinst() {
        gnome2_schemas_update
	ubuntu-versionator_pkg_postinst
}

pkg_postrm() {
        gnome2_schemas_update
}
