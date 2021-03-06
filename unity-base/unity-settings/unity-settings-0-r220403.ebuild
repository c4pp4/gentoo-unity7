# Copyright 1999-2022 Gentoo Authors
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
KEYWORDS="~amd64"
IUSE="+files lowgfx +music +photos +ubuntu-cursor +ubuntu-sounds +video yaru"
RESTRICT="binchecks strip test"

RDEPEND="
	media-fonts/ubuntu-font-family
	x11-themes/ubuntu-themes
	x11-themes/ubuntu-wallpapers

	ubuntu-cursor? ( x11-themes/vanilla-dmz-xcursors )
	ubuntu-sounds? ( x11-themes/ubuntu-sounds )
	yaru? (
		x11-themes/ubuntu-unity-backgrounds
		x11-themes/yaru-unity7[extra]
	)
"
PDEPEND="unity-lenses/unity-lens-meta[files=,music=,photos=,video=]"

S="${FILESDIR}"

src_install() {
	local \
		gschema="10_unity-settings.gschema.override" \
		gschema_dir="/usr/share/glib-2.0/schemas"

	insinto "${gschema_dir}"
	newins "${FILESDIR}"/unity-settings.gsettings-override "${gschema}"
	use yaru && newins "${FILESDIR}"/ubuntu-unity-yaru.gsettings-override 11_ubuntu-unity-yaru.gschema.override

	if use ubuntu-cursor || use yaru; then
		# Do the following only if there is no file collision detected #
		local index_dir="/usr/share/cursors/xorg-x11/default"
		[[ -e "${EROOT}${index_dir}"/index.theme ]] \
			&& local index_owner=$(portageq owners "${EROOT}/" "${EROOT}${index_dir}"/index.theme 2>/dev/null | grep "${CATEGORY}/${PN}-[0-9]" 2>/dev/null)
		# Pass when not null or unset #
		if [[ -n "${index_owner-unset}" ]]; then
			insinto "${index_dir}"
			doins "${FILESDIR}"/index.theme
		fi
	else
		sed -i "/cursor-theme/d" "${ED}${gschema_dir}/${gschema}" || die
	fi

	use yaru && [[ -f "${ED}${index_dir}"/index.theme ]] && \
		( sed -i "s/DMZ-White/Yaru/" "${ED}${index_dir}"/index.theme || die )

	use ubuntu-sounds || sed -i \
		-e "/org.gnome.desktop.sound/,+2 d" \
		"${ED}${gschema_dir}/${gschema}" || die

	use lowgfx && echo -e \
		"\n[com.canonical.Unity:Unity]\nlowgfx = true" \
		>> "${ED}${gschema_dir}/${gschema}"

	exeinto /etc/X11/xinit/xinitrc.d
	doexe "${FILESDIR}/95unity-gtk-theme"

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
