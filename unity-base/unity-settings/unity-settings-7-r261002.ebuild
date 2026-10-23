# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=

inherit gnome2-utils ubuntu-versionator

DESCRIPTION="Default settings for the Unity"
HOMEPAGE="https://launchpad.net/ubuntu/+source/ubuntu-settings"
unset SRC_URI
S="${WORKDIR}"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="amd64"
IUSE="+accessibility classic-fonts classic-theme +files lowgfx +music +photos +ubuntu-sounds +video"
RESTRICT="binchecks strip test"

# media-fonts/ubuntu-font-family dependency #
# is required by media-fonts/fonts-meta package #
RDEPEND="
	|| (
		media-fonts/fonts-ubuntu
		media-fonts/ubuntu-font-family
	)
	media-libs/freetype:2[adobe-cff,cleartype-hinting]
	x11-themes/ubuntu-themes
	x11-themes/ubuntu-unity-backgrounds
	x11-themes/ubuntu-wallpapers
	x11-themes/yaru-theme

	classic-fonts? ( media-fonts/ubuntu-font-family )
	classic-theme? ( x11-themes/vanilla-dmz-xcursors )
	ubuntu-sounds? ( x11-themes/ubuntu-sounds )
"
PDEPEND="unity-lens/unity-lens-meta[files=,music=,photos=,video=]"

src_install() {
	local \
		gschema="10_ubuntu-unity.gschema.override" \
		gschema_dir="/usr/share/glib-2.0/schemas"

	insinto "${gschema_dir}"
	newins "${FILESDIR}"/ubuntu-unity.gsettings-override "${gschema}"
	use classic-theme && newins "${FILESDIR}"/classic-unity.gsettings-override 11_classic-unity.gschema.override

	# An existing index.theme created by the user is kept, see pkg_preinst #
	local index_dir="/usr/share/cursors/xorg-x11/default"
	insinto "${index_dir}"
	doins "${FILESDIR}"/index.theme

	if use classic-theme; then
		sed -i "s/Yaru/DMZ-White/" "${ED}${index_dir}"/index.theme || die
		grep -Fq "DMZ-White" "${ED}${index_dir}"/index.theme || die
	fi

	if ! use accessibility; then
		sed -i \
			-e "/toolkit-accessibility/d" \
			"${ED}${gschema_dir}/${gschema}" || die
		! grep -Fq "toolkit-accessibility" "${ED}${gschema_dir}/${gschema}" || die
	fi

	if ! use ubuntu-sounds; then
		sed -i \
			-e "/org.gnome.desktop.sound/,+2 d" \
			"${ED}${gschema_dir}/${gschema}" || die
		! grep -Fq "org.gnome.desktop.sound" "${ED}${gschema_dir}/${gschema}" || die
	fi

	if use lowgfx; then
		echo -e \
			"\n[com.canonical.Unity:Unity]\nlowgfx = true" \
			>> "${ED}${gschema_dir}/${gschema}" || die
	fi

	# Scopes: files, music, photos, video #
	local \
		dash="'files.scope','video.scope','music.scope','photos.scope'," \
		dlen

	dlen=${#dash}

	use files || dash="${dash/\'files.scope\',}"
	use music || dash="${dash/\'music.scope\',}"
	use photos || dash="${dash/\'photos.scope\',}"
	use video || dash="${dash/\'video.scope\',}"

	if [[ ${#dash} -ne ${dlen} ]]; then
		echo -e \
			"\n[com.canonical.Unity.Dash:Unity]\nscopes = ['home.scope','applications.scope',${dash}'social.scope']" \
			>> "${ED}${gschema_dir}/${gschema}" || die
	fi

	# Add language-selector-0.230 fontconfig #
	insinto /etc/fonts/conf.avail
	doins -r "${FILESDIR}"/language-selector/*
	if use classic-fonts; then
		mv "${ED}"/etc/fonts/conf.avail/56-language-selector-prefer.conf \
			"${ED}"/etc/fonts/conf.avail/64-language-selector-prefer.conf || die
	fi
	einfo "Creating fontconfig configuration symlinks ..."
	local f
	for f in "${ED}"/etc/fonts/conf.avail/*; do
		f=${f##*/}
		echo " * ${f}"
		dosym -r /etc/fonts/conf.avail/"${f}" /etc/fonts/conf.d/"${f}"
	done
}

pkg_preinst() {
	local \
		index="/usr/share/cursors/xorg-x11/default/index.theme" \
		content x

	# Modified gnome2_schemas_savelist to find *.gschema.override files #
	export GNOME2_ECLASS_GLIB_SCHEMAS=$(find "${ED}/usr/share/glib-2.0/schemas" -name "*.gschema.override" 2>/dev/null)

	[[ -e ${EROOT}${index} ]] || return

	# Replace only the index.theme installed by this package #
	content=$(<"${EROOT}${index}") || die
	for x in Yaru DMZ-White; do
		[[ ${content} == $'[Icon Theme]\nInherits='${x} ]] && return
	done

	# Keep the existing user's index.theme #
	rm "${ED}${index}" || die
	elog "Existing ${index} has been kept untouched."
}

pkg_postinst() {
	gnome2_schemas_update
	ubuntu-versionator_pkg_postinst
}

pkg_postrm() {
	gnome2_schemas_update
}
