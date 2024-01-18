# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

COMMIT="6a09b01b13637454c268a4e1c050a266"

inherit java-pkg-2 cmake

DESCRIPTION="Global menu for Java applications"
HOMEPAGE="https://gitlab.com/vala-panel-project/vala-panel-appmenu/tree/master/subprojects/jayatana"
SRC_URI="https://gitlab.com/vala-panel-project/vala-panel-appmenu/uploads/${COMMIT}/${P}.tar.xz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64"
IUSE="+system-wide"
RESTRICT="mirror test"

RDEPEND="
	>=dev-libs/glib-2.40.0:2
	>=dev-libs/libdbusmenu-16.04.0
	>=virtual/jdk-1.7.0
	>=x11-libs/libxkbcommon-0.5.0
"
DEPEND="${RDEPEND}"

src_prepare() {
	java-pkg-2_src_prepare

	# Fix .jar dir #
	java-pkg_init_paths_
	sed -i "s:\${CMAKE_INSTALL_DATAROOTDIR}/java:${JAVA_PKG_JARDEST}:" java/CMakeLists.txt || die
	sed -i "s:@CMAKE_INSTALL_FULL_DATAROOTDIR@/java:${JAVA_PKG_JARDEST}:" lib/config.h.in || die

	# Remove JDK 9+ related option #
	local active_vm=$(java-config -f)
	[[ ${active_vm##*-} == "8" ]] && ( sed -i \
		"/--add-exports/d" java/CMakeLists.txt || die )

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DENABLE_JAYATANA=ON
		-DSTANDALONE=OFF
	)
	cmake_src_configure
}

src_install() {
	DOCS=(
		AUTHORS
		LICENSE
		README.md
	)
	cmake_src_install

	java-pkg_regjar "${ED}"/"${JAVA_PKG_JARDEST}"/*.jar

	if use system-wide; then
		exeinto /etc/X11/xinit/xinitrc.d
		sed "s:JAGDEST:${JAVA_PKG_JARDEST}:" "${FILESDIR}"/90jayatana > 90jayatana
		doexe 90jayatana
	fi
}

pkg_postinst() {
	if ! use system-wide; then
		echo
		elog "Enabling Jayatana"
		elog "1. System-wide way (recommended only if you have many Java programs with menus):"
		elog "   Set 'system-wide' USE flag."
		elog "2. Application-specific ways (useful if you usually have one or 2 Java programs, like Android Studio) and if above does not work."
		elog "   2.1. Intellij programs (Idea, PhpStorm, CLion, Android Studio)"
		elog "        Edit *.vmoptions file, and add -javaagent:${JAVA_PKG_JARDEST}/${PN}ag.jar to the end of file."
		elog "        Edit *.properties file, and add linux.native.menu=true to the end of it."
		elog "   2.2. Netbeans"
		elog "        Edit netbeans.conf, and add -J-javaagent:${JAVA_PKG_JARDEST}/${PN}ag.jar to the end of it."
		elog "3. Enable agent via desktop file (for any single application)"
		elog "   Add -javaagent:${JAVA_PKG_JARDEST}/${PN}ag.jar after Exec or TryExec line of application's desktop file (if application executes JAR directly). If application executes JAR via wrapper, and this option to the end of JVM options for running actual JAR."
		echo
	fi
}
