# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=

inherit desktop gnome2-utils systemd ubuntu-versionator

DESCRIPTION="Utility to change the LightDM greeter being used"
HOMEPAGE="https://www.gentoo.org/"
SRC_URI="${UURL}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="binchecks strip test"

RDEPEND="
	gnome-base/dconf
	gnome-extra/cinnamon-session[systemd]
	gnome-extra/cinnamon-settings-daemon[systemd]
	sys-apps/dbus
	sys-apps/systemd
	unity-base/unity
	unity-base/unity-settings-daemon
	x11-misc/xdg-user-dirs-gtk
"

S="${WORKDIR}/${PN}"

src_install() {
	insinto /usr/share/nemo/actions
	doins *.nemo_action

	insinto /usr/share/lightdm/lightdm.conf.d
	doins 50-unity.conf

	# Autostart nemo-desktop to manage Unity7 desktop and icons #
	sed -i "/NoDisplay/{s/false/true/}" "${S}"/nemo-unity-autostart.desktop || die
	insinto /etc/xdg/autostart
	newins nemo-unity-autostart.desktop unity-nemo-desktop.desktop

	sed -i "/xdg/d" "${S}"/"${PN}".target || die # xdg .desktop autostart is managed via cinnamon-session #
	systemd_douserunit "${PN}".target
	systemd_douserunit "${PN}".service

	exeinto /usr/bin
	doexe "${PN}"
	doexe "${FILESDIR}"/"${PN}"-quit

	insinto /usr/share/cinnamon-session/sessions
	doins unity.session

	insinto /usr/share/xsessions
	doins unity.desktop

	# Start gnome-session using systemd #
	exeinto /usr/libexec
	doexe run-systemd-session

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
