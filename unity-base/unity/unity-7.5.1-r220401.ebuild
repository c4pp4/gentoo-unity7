# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{8..10} )

UVER=+22.04.20211026.2
UREV=0ubuntu1

inherit gnome2 cmake-utils pam python-single-r1 systemd ubuntu-versionator

DESCRIPTION="The Ubuntu Unity Desktop"
HOMEPAGE="https://launchpad.net/unity"
SRC_URI="${UURL}-${UREV}.tar.xz"

LICENSE="GPL-3 LGPL-3"
SLOT="0/${PV}"
KEYWORDS="~amd64"
IUSE="+branding debug doc gles2 +hud +nemo +pch systray"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RESTRICT="${RESTRICT} test"

COMMON_DEPEND="
	>=dev-libs/appstream-glib-0.5.1
	>=dev-libs/atk-2.2.0
	>=dev-libs/dee-1.2.6:=[${PYTHON_SINGLE_USEDEP}]
	>=dev-libs/glib-2.41.1:2
	>=dev-libs/json-glib-1.5.2
	>=dev-libs/libdbusmenu-0.4.2[gtk3]
	>=dev-libs/libindicator-0.12.2:3
	>=dev-libs/libsigc++-2.8.0:2
	>=dev-libs/libunity-7.1.4:=[${PYTHON_SINGLE_USEDEP}]
	>=dev-libs/libunity-misc-4.0.4
	>=gnome-extra/zeitgeist-0.9.9[${PYTHON_SINGLE_USEDEP}]
	>=sys-libs/pam-0.99.7.1
	>=unity-base/bamf-0.5.3:=
	>=unity-base/compiz-0.9.13.1:=[gles2=,${PYTHON_SINGLE_USEDEP}]
	>=unity-base/gsettings-ubuntu-touch-schemas-0.0.7
	>=unity-base/nux-4.0.6:=[debug?,gles2=]
	>=unity-base/unity-settings-daemon-15.04.1
	>=unity-indicators/ido-13.10.0
	>=x11-libs/cairo-1.14.0
	>=x11-libs/gtk+-3.19.12:3
	>=x11-libs/libnotify-0.7.0
	>=x11-libs/libXfixes-5.0.1
	>=x11-libs/pango-1.22.0
	>=x11-libs/libXi-1.7.1.901

	${PYTHON_DEPS}
"
RDEPEND="${COMMON_DEPEND}
	>=app-accessibility/at-spi2-atk-2.5.3:2
	gnome-base/dconf
	gnome-base/gnome-session[systemd]
	gnome-base/nautilus
	media-libs/libglvnd
	sys-auth/polkit-pkla-compat
	>=sys-devel/gcc-7
	>=sys-libs/glibc-2.29
	unity-base/session-migration[${PYTHON_SINGLE_USEDEP}]
	unity-base/session-shortcuts
	unity-base/unity-control-center
	unity-base/unity-language-pack[branding=]
	unity-extra/unity-greeter
	unity-indicators/unity-indicators-meta
	unity-scopes/unity-scope-home
	>=x11-libs/gdk-pixbuf-2.22.0:2
	>=x11-libs/libX11-1.2.99.901
	x11-libs/libXext
	x11-libs/libXrender
	>=x11-themes/unity-asset-pool-0.8.18

	!gles2? ( >=media-libs/glewmx-1.12.0 )
	hud? ( unity-base/hud )
	nemo? ( gnome-extra/nemo )

	$(python_gen_cond_dep 'dev-python/pygobject:3[${PYTHON_USEDEP}]')
"
DEPEND="${COMMON_DEPEND}
	dev-libs/libxslt
	>=dev-libs/xpathselect-1.4
	gnome-base/gsettings-desktop-schemas
	gnome-base/gnome-desktop:3=
	sys-apps/dbus[systemd,X]
	>=unity-base/geis-2.0.10[${PYTHON_SINGLE_USEDEP}]
	x11-libs/libXtst
	x11-libs/startup-notification
	x11-libs/xcb-util-wm
	x11-themes/gtk-engines-murrine

	$(python_gen_cond_dep 'dev-libs/boost:=[python,${PYTHON_USEDEP}]')
"
BDEPEND="
	>=dev-util/intltool-0.35.0
	virtual/pkgconfig

	doc? ( app-doc/doxygen[dot] )
"

S="${WORKDIR}/${PN}"

src_prepare() {
	use branding && ( sed -i \
			-e 's:"Ubuntu Desktop":"Gentoo Unity⁷ Desktop":g' \
			panel/PanelMenuView.cpp || die )

	# Preprocessor fixes #
	if ! use pch; then
		sed -i '/#include "GLibWrapper.h"/a #include <iostream>/' UnityCore/GLibWrapper.cpp || die
		sed -i '/#include <functional>/a #include <string>' UnityCore/GLibSource.h || die
		sed -i '/#include "GLibWrapper.h"/a #include <vector>' UnityCore/ScopeData.h || die
		sed -i '/#include <NuxCore\/Property.h>/a #include <vector>' unity-shared/ThemeSettings.h || die
	fi

	use systray && eapply "${FILESDIR}/show-all-in-systray.diff" # see https://launchpad.net/bugs/974480 #

	# Setup Unity side launcher default applications #
	sed -i \
		-e "/firefox/r ${FILESDIR}/www-clients" \
		-e '/ubiquity/d' \
		-e '/org.gnome.Software/d' \
		data/com.canonical.Unity.gschema.xml || die

	# Change ubuntu to unity #
	sed -i \
		-e 's:SESSION=ubuntu:SESSION=unity:g' \
		{data/unity7.conf.in,services/unity-panel-service.conf.in} || die

	sed -i \
		-e 's:ubuntu.session:unity.session:g' \
		tools/{systemd,upstart}-prestart-check || die

	# Related to /etc/os-release NAME check #
	sed -i \
		-e 's:"Ubuntu":"Gentoo":' \
		panel/PanelMenuView.cpp || die

	# Don't kill -9 unity-panel-service when launched using PANEL_USE_LOCAL_SERVICE env variable #
	#  It slows down the launch of unity-panel-service in lockscreen mode #
	sed -i \
		-e '/killall -9 unity-panel-service/,+1 d' \
		UnityCore/DBusIndicators.cpp || die

	# New stable dev-libs/boost-1.71 compatibility changes #
	sed -i \
		-e 's:boost/utility.hpp:boost/next_prior.hpp:g' \
		launcher/FavoriteStorePrivate.cpp || die

	# 'After=graphical-session-pre.target' must be explicitly set in the unit files that require it #
	# Relying on the upstart job /usr/share/upstart/systemd-session/upstart/systemd-graphical-session.conf #
	#	to create "$XDG_RUNTIME_DIR/systemd/user/${unit}.d/graphical-session-pre.conf" drop-in units #
	#	results in weird race problems on desktop logout where the reliant desktop services #
	#	stop in a different jumbled order each time #
	sed -i \
		-e 's:After=\(unity-settings-daemon.service\):After=graphical-session-pre.target gnome-session.service bamfdaemon.service \1:' \
		data/unity7.service.in || die

	# Apps launched from u-c-c need GTK_MODULES environment variable with unity-gtk-module value #
	#	to use unity global/titlebar menu. Disable unity-gtk-module.service as it only sets #
	#	dbus/systemd environment variable. We are providing xinit.d script to set GTK_MODULES #
	#	environment variable to load unity-gtk-module (see unity-base/unity-gtk-module package) #
	sed -i \
		-e 's:unity-gtk-module.service ::' \
		data/unity7.service.in || die

	# Don't use drop-down menu icon from Adwaita theme as it's too dark since v3.30 #
	sed -i \
		-e "s/go-down-symbolic/drop-down-symbolic/" \
		decorations/DecorationsMenuDropdown.cpp || die

	# Fix build.ninja: lexing error #
	sed -i \
		-e '/echo "/{s/"/\\"/g}' \
		-e '/bzr log/{s/"/\\"/g}' \
		-e 's/\\n/\\\\n/' \
		CMakeLists.txt || die

	# Exp #1: Clean up pam file installation as used in lockscreen (LP# 1305440), provide own pam, see src_install #
	# Exp #2: Disable recompiling GSettings schemas inside sandbox #
	sed -i \
		-e "/(pam)/d" \
		-e "/Compiling GSettings schemas/,+1 d" \
		data/CMakeLists.txt || die

	# Fix libdir #
	sed -i \
		-e "s:/usr/lib/:/usr/$(get_libdir)/:" \
		tools/compiz-profile-selector.in || die

	python_fix_shebang tools

	ubuntu-versionator_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_GLES=$(usex gles2 ON OFF)
		-DCMAKE_INSTALL_LOCALSTATEDIR="${EPREFIX}/var"
		-DCMAKE_INSTALL_LIBDIR=$(get_libdir)
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr"
		-DCMAKE_INSTALL_SYSCONFDIR="${EPREFIX}/etc"
		-DCOMPIZ_BUILD_WITH_RPATH=OF
		-DCOMPIZ_PACKAGING_ENABLED=ON
		-DCOMPIZ_PLUGIN_INSTALL_TYPE=package
		-DENABLE_UNIT_TESTS=OFF
		-DI18N_SUPPORT=OFF
		-Duse_pch=$(usex pch ON OFF)
		-Wno-dev
	)
	CMAKE_BUILD_TYPE="None" cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	if use branding; then
		insinto /usr/share/unity/icons
		# Gentoo dash launcher icon #
		doins "${FILESDIR}/branding/launcher_bfb.svg"
		# Gentoo logo on lock-screen on multi head system
		doins "${FILESDIR}/branding/lockscreen_cof.png"
	fi

	if use debug; then
		exeinto /etc/X11/xinit/xinitrc.d/
		doexe "${FILESDIR}/99unity-debug"
	fi

	exeinto /etc/X11/xinit/xinitrc.d/
	doexe "${FILESDIR}/70im-config"			# Configure input method (xim/ibus)
	doexe "${FILESDIR}/99unity-session_systemd"	# Unity session environment setup and 'startx' launcher

	# Create /etc/pam.d/unity #
	pamd_mimic system-local-login ${PN} auth account session

	# Set base desktop user privileges #
	insinto /var/lib/polkit-1/localauthority/10-vendor.d
	doins "${FILESDIR}/com.ubuntu.desktop.pkla"
	fowners root:polkitd /var/lib/polkit-1/localauthority/10-vendor.d/com.ubuntu.desktop.pkla

	# Make 'unity-session.target' systemd user unit auto-start 'unity7.service' #
	dosym $(systemd_get_userunitdir)/unity7.service $(systemd_get_userunitdir)/unity-session.target.requires/unity7.service
	dosym $(systemd_get_userunitdir)/unity-settings-daemon.service $(systemd_get_userunitdir)/unity-session.target.wants/unity-settings-daemon.service
	dosym $(systemd_get_userunitdir)/window-stack-bridge.service $(systemd_get_userunitdir)/unity-session.target.wants/window-stack-bridge.service

	unity-panel-service_dosym() {
		local x
		for x in $2; do
			dosym $(systemd_get_userunitdir)/indicator-${x}.service $(systemd_get_userunitdir)/$1.service.wants/indicator-${x}.service
		done
	}
	# Top panel systemd indicator services required for unity-panel-service #
	unity-panel-service_dosym "unity-panel-service" "application bluetooth datetime keyboard messages power printers session sound"
	# Top panel systemd indicator services required for unity-panel-service-lockscreen #
	unity-panel-service_dosym "unity-panel-service-lockscreen" "datetime keyboard power session sound"

	exeinto /usr/share/session-migration/scripts
	doexe tools/migration-scripts/*

	insinto /usr/lib/compiz/migration
	doins tools/convert-files/*.convert

	dosym ../../gnome-control-center/keybindings/50-unity-launchers.xml \
		/usr/share/unity-control-center/keybindings/50-unity-launchers.xml
}

pkg_postinst() {
	ubuntu-versionator_pkg_postinst

	echo
	elog "If you use a custom ~/.xinitrc to startx then you should"
	elog "add the following to the top of your ~/.xinitrc file"
	elog "to ensure all needed services are started:"
	elog
	elog 'XSESSION=unity'
	elog 'if [ -d /etc/X11/xinit/xinitrc.d ] ; then'
	elog '    for f in /etc/X11/xinit/xinitrc.d/* ; do'
	elog '        [ -x "$f" ] && . "$f"'
	elog '    done'
	elog '    unset f'
	elog 'fi'
	echo
}
