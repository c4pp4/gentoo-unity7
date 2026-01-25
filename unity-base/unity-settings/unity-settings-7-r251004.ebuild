# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=

inherit gnome2-utils ubuntu-versionator

DESCRIPTION="Default settings for the Unity"
HOMEPAGE="https://launchpad.net/ubuntu/+source/ubuntu-settings"
SRC_URI=""

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="amd64"
IUSE="+accessibility classic-fonts classic-theme +files +fontconfig lowgfx +music +photos +ubuntu-sounds +video"
REQUIRED_USE="classic-fonts? ( fontconfig )"
RESTRICT="binchecks strip test"

# media-fonts/ubuntu-font-family dependency #
# is required by media-fonts/fonts-meta package #
RDEPEND="
	|| (
		media-fonts/fonts-ubuntu
		media-fonts/ubuntu-font-family
	)
	x11-themes/ubuntu-themes
	x11-themes/ubuntu-unity-backgrounds
	x11-themes/ubuntu-wallpapers
	x11-themes/yaru-theme

	classic-fonts? ( media-fonts/ubuntu-font-family )
	classic-theme? ( x11-themes/vanilla-dmz-xcursors )
	fontconfig? ( media-libs/freetype:2[adobe-cff,cleartype-hinting] )
	ubuntu-sounds? ( x11-themes/ubuntu-sounds )
"
PDEPEND="
	unity-base/gentoo-unity-env[fontconfig=]
	unity-lenses/unity-lens-meta[files=,music=,photos=,video=]
"

S="${FILESDIR}"

src_install() {
	local \
		gschema="10_ubuntu-unity.gschema.override" \
		gschema_dir="/usr/share/glib-2.0/schemas"

	insinto "${gschema_dir}"
	newins "${FILESDIR}"/ubuntu-unity.gsettings-override "${gschema}"
	use classic-theme && newins "${FILESDIR}"/classic-unity.gsettings-override 11_classic-unity.gschema.override

	# Do the following only if there is no file collision detected #
	local index_dir="/usr/share/cursors/xorg-x11/default"
	[[ -e "${EROOT}${index_dir}"/index.theme ]] \
		&& local index_owner=$("${PORTAGE_QUERY_TOOL}" owners "${EROOT}/" "${EROOT}${index_dir}"/index.theme 2>/dev/null | grep "${CATEGORY}/${PN}-[0-9]" 2>/dev/null)
	# Pass when not null or unset #
	if [[ -n "${index_owner-unset}" ]]; then
		insinto "${index_dir}"
		doins "${FILESDIR}"/index.theme
	fi

	use classic-theme && [[ -f "${ED}${index_dir}"/index.theme ]] && \
		( sed -i "s/Yaru/DMZ-White/" "${ED}${index_dir}"/index.theme || die )

	use accessibility || sed -i \
		-e "/toolkit-accessibility/d" \
		"${ED}${gschema_dir}/${gschema}" || die

	use ubuntu-sounds || sed -i \
		-e "/org.gnome.desktop.sound/,+2 d" \
		"${ED}${gschema_dir}/${gschema}" || die

	use lowgfx && echo -e \
		"\n[com.canonical.Unity:Unity]\nlowgfx = true" \
		>> "${ED}${gschema_dir}/${gschema}"

	# Scopes: files, music, photos, video #
	local \
		dash="'files.scope','video.scope','music.scope','photos.scope'," \
		dlen

	dlen=${#dash}

	use files || dash="${dash/\'files.scope\',}"
	use music || dash="${dash/\'music.scope\',}"
	use photos || dash="${dash/\'photos.scope\',}"
	use video || dash="${dash/\'video.scope\',}"

	[[ ${#dash} -ne ${dlen} ]] && echo -e \
		"\n[com.canonical.Unity.Dash:Unity]\nscopes = ['home.scope','applications.scope',${dash}'social.scope']" \
		>> "${ED}${gschema_dir}/${gschema}"


	# Add language-selector-0.228 fontconfig #
	if use fontconfig; then
		insinto /etc/fonts/conf.avail
		doins -r "${FILESDIR}"/language-selector/*
		use classic-fonts \
			&& mv "${ED}"/etc/fonts/conf.avail/56-language-selector-prefer.conf \
				"${ED}"/etc/fonts/conf.avail/64-language-selector-prefer.conf
		einfo "Creating fontconfig configuration symlinks ..."
		local f
		for f in "${ED}"/etc/fonts/conf.avail/*; do
			f=${f##*/}
			echo " * ${f}"
			dosym -r /etc/fonts/conf.avail/"${f}" /etc/fonts/conf.d/"${f}"
		done
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
