# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=

inherit desktop gnome2-utils systemd ubuntu-versionator

DESCRIPTION="Session files and startup scripts for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/ubuntu/+source/unity-session"
SRC_URI="${UURL}.tar.xz"
S="${WORKDIR}/${PN}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE="systemd"
RESTRICT="binchecks strip test"

RDEPEND="
	gnome-base/dconf
	gnome-extra/cinnamon-session[systemd=]
	gnome-extra/cinnamon-settings-daemon[systemd=]
	sys-apps/dbus
	unity-base/unity[systemd=]
	unity-base/unity-settings-daemon
	x11-misc/xdg-user-dirs-gtk

	systemd? ( sys-apps/systemd )
	!systemd? ( sys-auth/elogind )
"

PATCHES=( "${FILESDIR}"/release-sound-card-at-session-end.patch )

src_install() {
	insinto /usr/share/nemo/actions
	doins *.nemo_action

	insinto /usr/share/lightdm/lightdm.conf.d
	doins 50-unity.conf

	# Autostart nemo-desktop to manage Unity7 desktop and icons #
	sed -i "/NoDisplay/{s/false/true/}" "${S}"/nemo-unity-autostart.desktop || die
	grep -qx "NoDisplay=true" "${S}"/nemo-unity-autostart.desktop || die
	insinto /etc/xdg/autostart
	newins nemo-unity-autostart.desktop unity-nemo-desktop.desktop

	exeinto /usr/bin
	doexe "${FILESDIR}"/"${PN}"-quit

	if use systemd; then
		sed -i "/xdg/d" "${S}"/"${PN}".target || die # xdg .desktop autostart is managed via cinnamon-session #
		! grep -Fq "xdg-desktop-autostart.target" "${S}"/"${PN}".target || die
		systemd_douserunit "${PN}".target
		systemd_douserunit "${PN}".service

		doexe "${PN}"

		# Start cinnamon-session using systemd #
		exeinto /usr/libexec
		doexe run-systemd-session
	else
		# Start cinnamon-session directly #
		newexe "${FILESDIR}"/"${PN}"-openrc "${PN}"
	fi

	sed -i "/DesktopName/{s/:ubuntu//}" "${S}"/unity.session || die
	grep -qx "DesktopName=Unity:Unity7" "${S}"/unity.session || die
	insinto /usr/share/cinnamon-session/sessions
	doins unity.session

	sed -i "/DesktopNames/{s/ubuntu;//}" "${S}"/unity.desktop || die
	grep -qx "DesktopNames=Unity;Unity7;" "${S}"/unity.desktop || die
	insinto /usr/share/xsessions
	doins unity.desktop

	# From gnome-extra/cinnamon-6.6.7 package #
	insinto /usr/share/glib-2.0/schemas
	newins "${FILESDIR}"/org.cinnamon.gschema.xml \
		org.cinnamon."${PN}".gschema.xml

	# 'startx' visible via the XSESSION variable #
	exeinto /etc/X11/Sessions
	newexe "${FILESDIR}"/unity.xsession unity

	# Set Unity XDG desktop session variables #
	exeinto /etc/X11/xinit/xinitrc.d
	doexe "${FILESDIR}"/15-xdg-data-unity

	# Enables and fills $DESKTOP_SESSION variable #
	#  for sessions started using 'startx' #
	exeinto /etc/X11/xinit/xinitrc.d/
	doexe "${FILESDIR}"/05-unity-desktop-session

	# xdg-desktop-portal backends for XDG_CURRENT_DESKTOP=Unity #
	insinto /usr/share/xdg-desktop-portal
	doins "${FILESDIR}"/unity-portals.conf

	# Unity default mimeapps #
	newmenu "${FILESDIR}"/defaults.list unity-mimeapps.list
}

pkg_preinst() {
	gnome2_schemas_savelist
}

pkg_postinst() {
	gnome2_schemas_update
	ubuntu-versionator_pkg_postinst
}

pkg_postrm() {
	gnome2_schemas_update
}
