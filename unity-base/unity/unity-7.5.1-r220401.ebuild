# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{8..10} )

UVER="+22.04.20211026.2"
UREV="0ubuntu1"

inherit cmake-utils distutils-r1 gnome2 pam systemd ubuntu-versionator xdummy

DESCRIPTION="The Ubuntu Unity Desktop"
HOMEPAGE="https://launchpad.net/unity"
SRC_URI="${UURL}-${UREV}.tar.xz"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
#KEYWORDS="~amd64"
IUSE="+branding debug doc gles2 +hud +nemo pch systray test"

S="${WORKDIR}/${PN}"

RDEPEND="app-i18n/ibus[gtk,gtk2]
	>=sys-apps/systemd-232
	sys-auth/polkit-pkla-compat
	unity-base/gsettings-ubuntu-touch-schemas
	unity-base/session-shortcuts
	unity-base/unity-language-pack[branding=]
	x11-themes/humanity-icon-theme
	x11-themes/gtk-engines-murrine
	x11-themes/unity-asset-pool
	hud? ( unity-base/hud )
	nemo? ( gnome-extra/nemo )"
DEPEND="${RDEPEND}
	!sys-apps/upstart
	!unity-base/dconf-qt
	dev-libs/appstream-glib
	>=dev-libs/boost-1.71:=
	dev-libs/dee:=
	dev-libs/dbus-glib
	dev-libs/icu:=
	dev-libs/libappindicator
	dev-libs/libdbusmenu:=
	dev-libs/libffi
	dev-libs/libindicate[gtk,introspection]
	dev-libs/libindicator
	dev-libs/libsigc++:2
	dev-libs/libunity
	dev-libs/libunity-misc:=
	dev-libs/xpathselect
	gnome-base/gnome-desktop:3=
	gnome-base/gnome-menus:3
	gnome-base/gnome-session[systemd]
	gnome-base/gsettings-desktop-schemas
	gnome-extra/polkit-gnome:0
	media-libs/glew:=
	media-libs/mesa
	sys-apps/dbus[systemd,X]
	sys-auth/pambase
	unity-base/bamf:=
	unity-base/compiz:=[gles2=]
	unity-base/nux:=[debug?,gles2=]
	unity-base/overlay-scrollbar
	unity-base/unity-control-center
	unity-base/unity-settings-daemon
	x11-base/xorg-server[dmx]
	>=x11-libs/cairo-1.13.1
	x11-libs/libXfixes
	x11-libs/startup-notification
	unity-base/unity-gtk-module
	doc? ( app-doc/doxygen )
	test? ( >=dev-cpp/gtest-1.8.1
		dev-python/autopilot
		dev-util/dbus-test-runner
		sys-apps/xorg-gtest )"

src_prepare() {
	## Disable source trying to run it's own dummy-xorg-test-runner.sh script ##
	use test && sed -i \
		-e 's:set (DUMMY_XORG_TEST_RUNNER.*:set (DUMMY_XORG_TEST_RUNNER /bin/true):g' \
		tests/CMakeLists.txt

	# https://launchpad.net/bugs/974480 #
	use systray && eapply "${FILESDIR}/show-all-in-systray.diff"

	# Setup Unity side launcher default applications #
	sed -i \
		-e "/firefox/r ${FILESDIR}/www-clients" \
		-e '/ubiquity/d' \
		-e '/org.gnome.Software/d' \
		data/com.canonical.Unity.gschema.xml || die

	sed -i \
		-e 's:"Ubuntu":"Gentoo":g' \
		panel/PanelMenuView.cpp

	use branding && sed -i \
			-e 's:"Ubuntu Desktop":"Gentoo Unity⁷ Desktop":g' \
			panel/PanelMenuView.cpp

	# Remove testsuite cmake installation #
	sed -i \
		-e '/setup.py install/d' \
		tests/CMakeLists.txt || die "Sed failed for tests/CMakeLists.txt"

	# Unset CMAKE_BUILD_TYPE env variable so that cmake-utils.eclass doesn't try to 'append-cppflags -DNDEBUG' #
	#       resulting in build failure with 'fatal error: unitycore_pch.hh: No such file or directory' #
	export CMAKE_BUILD_TYPE=none

	# Don't kill -9 unity-panel-service when launched using PANEL_USE_LOCAL_SERVICE env variable #
	#  It slows down the launch of unity-panel-service in lockscreen mode #
	sed -i \
		-e '/killall -9 unity-panel-service/,+1d' \
		UnityCore/DBusIndicators.cpp || die "Sed failed for UnityCore/DBusIndicators.cpp"

	# New stable dev-libs/boost-1.71 compatibility changes #
	sed -i \
		-e 's:boost/utility.hpp:boost/next_prior.hpp:g' \
		launcher/FavoriteStorePrivate.cpp || die

	# DESKTOP_SESSION and SESSION is 'unity' not 'ubuntu' #
	sed -i \
		-e 's:SESSION=ubuntu:SESSION=unity:g' \
		-e 's:ubuntu-session:unity-session:g' \
		{data/unity7.conf.in,data/unity7.service.in,services/unity-panel-service.conf.in} || die "Sed failed for {data/unity7.conf.in,services/unity-panel-service.conf.in}"
	sed -i \
		-e 's:ubuntu.session:unity.session:g' \
		tools/{systemd,upstart}-prestart-check || die "Sed failed for tools/{systemd,upstart}-prestart-check"

	# 'After=graphical-session-pre.target' must be explicitly set in the unit files that require it #
	# Relying on the upstart job /usr/share/upstart/systemd-session/upstart/systemd-graphical-session.conf #
	#	to create "$XDG_RUNTIME_DIR/systemd/user/${unit}.d/graphical-session-pre.conf" drop-in units #
	#	results in weird race problems on desktop logout where the reliant desktop services #
	#	stop in a different jumbled order each time #
	sed -i \
		-e 's:After=\(unity-settings-daemon.service\):After=graphical-session-pre.target gnome-session.service bamfdaemon.service \1:' \
		data/unity7.service.in || die "Sed failed for data/unity7.service.in"

	# Apps launched from u-c-c need GTK_MODULES environment variable with unity-gtk-module value #
	#	to use unity global/titlebar menu. Disable unity-gtk-module.service as it sets only #
	#	dbus/systemd environment variable. We are providing xinit.d script to set GTK_MODULES #
	#	environment variable to load unity-gtk-module (see unity-base/unity-gtk-module package) #
	sed -i \
		-e 's:unity-gtk-module.service ::' \
		data/unity7.service.in

	# Don't use drop-down menu icon from Adwaita theme as it's too dark since v3.30 #
	sed -i \
		-e "s/go-down-symbolic/drop-down-symbolic/" \
		decorations/DecorationsMenuDropdown.cpp

	# Include directly iostream needed for std::ostream #
	sed -i 's/.*GLibWrapper.h.*/#include <iostream>\n&/' UnityCore/GLibWrapper.cpp

	# Fix building with GCC 10 #
	sed -i '/#include <functional>/a #include <string>' UnityCore/GLibSource.h
	sed -i '/#include "GLibWrapper.h"/a #include <vector>' UnityCore/ScopeData.h
	sed -i '/#include <NuxCore\/Property.h>/a #include <vector>' unity-shared/ThemeSettings.h

	ubuntu-versionator_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_GLES=$(usex gles2 ON OFF)
		-DBUILD_XORG_GTEST=$(usex test ON OFF)
		-DCMAKE_INSTALL_SYSCONFDIR=/etc
		-DCMAKE_INSTALL_LOCALSTATEDIR=/var
		-DCOMPIZ_BUILD_TESTING=$(usex test ON OFF)
		-DCOMPIZ_BUILD_WITH_RPATH=FALSE
		-DCOMPIZ_DISABLE_PLUGIN_UNITYMTGRABHANDLES=OFF
		-DCOMPIZ_DISABLE_PLUGIN_UNITYSHELL=OFF
		-DCOMPIZ_PACKAGING_ENABLED=TRUE
		-DCOMPIZ_PLUGIN_INSTALL_TYPE=package
		-DENABLE_UNIT_TESTS=$(usex test ON OFF)
		-DI18N_SUPPORT=OFF
		-Duse_pch=$(usex pch ON OFF)
	)
	cmake-utils_src_configure || die
}

src_compile() {
	if use test; then
		pushd tests/autopilot
			distutils-r1_src_compile
		popd
	fi

	cmake-utils_src_compile || die
}

src_test() {
	pushd ${CMAKE_BUILD_DIR}
		local XDUMMY_COMMAND="make check-headless"
		xdummymake
	popd
}

src_install() {
	pushd ${CMAKE_BUILD_DIR}
		addpredict /usr/share/glib-2.0/schemas/	# FIXME
		default
	popd

	if use debug; then
		exeinto /etc/X11/xinit/xinitrc.d/
		doexe "${FILESDIR}/99unity-debug"
	fi

	if use test; then
		pushd tests/autopilot
			distutils-r1_src_install
		popd
	fi

	python_fix_shebang "${ED}"

	if use branding; then
		insinto /usr/share/unity/icons
		# Gentoo dash launcher icon #
		doins "${FILESDIR}/branding/launcher_bfb.svg"
		# Gentoo logo on lock-screen on multi head system
		doins "${FILESDIR}/branding/lockscreen_cof.png"
	fi

	exeinto /etc/X11/xinit/xinitrc.d/
	doexe "${FILESDIR}/70im-config"			# Configure input method (xim/ibus)
	doexe "${FILESDIR}/99unity-session_systemd"	# Unity session environment setup and 'startx' launcher

	# Some newer multilib profiles have different /usr/lib(32,64)/ paths so insert the correct one
	local fixlib=$(get_libdir)
	sed -e "s:/usr/lib/:/usr/${fixlib}/:g" \
		-i "${ED}/etc/X11/xinit/xinitrc.d/70im-config" || die
	sed -e "/nux\/unity_support_test/{s/lib/${fixlib}/}" \
		-i "${ED}/usr/${fixlib}/unity/compiz-profile-selector" || die

	# Clean up pam file installation as used in lockscreen (LP# 1305440) #
	rm -rf "${ED}etc/pam.d"
	pamd_mimic system-local-login ${PN} auth account session

	# Set base desktop user privileges #
	insinto /var/lib/polkit-1/localauthority/10-vendor.d
	doins "${FILESDIR}/com.ubuntu.desktop.pkla"
	fowners root:polkitd /var/lib/polkit-1/localauthority/10-vendor.d/com.ubuntu.desktop.pkla

	# Make 'unity-session.target' systemd user unit auto-start 'unity7.service' #
	dosym $(systemd_get_userunitdir)/unity7.service $(systemd_get_userunitdir)/unity-session.target.requires/unity7.service
	# Disable service, see unity-gtk-module.service in src_prepare phase
	#dosym $(systemd_get_userunitdir)/unity-gtk-module.service $(systemd_get_userunitdir)/unity-session.target.wants/unity-gtk-module.service
	dosym $(systemd_get_userunitdir)/unity-settings-daemon.service $(systemd_get_userunitdir)/unity-session.target.wants/unity-settings-daemon.service
	dosym $(systemd_get_userunitdir)/window-stack-bridge.service $(systemd_get_userunitdir)/unity-session.target.wants/window-stack-bridge.service

	# Top panel systemd indicator services required for unity-panel-service #
	for each in {application,bluetooth,datetime,keyboard,messages,power,printers,session,sound}; do
		dosym $(systemd_get_userunitdir)/indicator-${each}.service $(systemd_get_userunitdir)/unity-panel-service.service.wants/indicator-${each}.service
	done

	# Top panel systemd indicator services required for unity-panel-service-lockscreen #
	for each in {datetime,keyboard,power,session,sound}; do
		dosym $(systemd_get_userunitdir)/indicator-${each}.service $(systemd_get_userunitdir)/unity-panel-service-lockscreen.service.wants/indicator-${each}.service
	done

	einstalldocs
}

pkg_postinst() {
	ubuntu-versionator_pkg_postinst

	echo
	elog "If you use a custom ~/.xinitrc to startx"
	elog "then you should add the following to the top of your ~/.xinitrc file"
	elog "to ensure all needed services are started:"
	elog ' XSESSION=unity'
	elog ' if [ -d /etc/X11/xinit/xinitrc.d ] ; then'
	elog '   for f in /etc/X11/xinit/xinitrc.d/* ; do'
	elog '     [ -x "$f" ] && . "$f"'
	elog '   done'
	elog ' unset f'
	elog ' fi'
	if use test; then
		elog
		elog "To run autopilot tests, do the following:"
		elog "cd /usr/$(get_libdir)/${EPYTHON}/site-packages/unity/tests"
		elog "and run 'autopilot run unity'"
	fi
	echo
}
