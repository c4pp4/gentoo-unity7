# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils java-utils-2

DESCRIPTION="Global Menu for Java applications"
HOMEPAGE="https://gitlab.com/vala-panel-project/vala-panel-appmenu/tree/master/subprojects/jayatana
	https://gitlab.com/vala-panel-project/vala-panel-appmenu/-/releases"

COMMIT="6a09b01b13637454c268a4e1c050a266"
SRC_URI="https://gitlab.com/vala-panel-project/vala-panel-appmenu/uploads/${COMMIT}/${P}.tar.xz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+system-wide"
RESTRICT="mirror"

DEPEND=">=dev-libs/glib-2.40.0
	>=dev-libs/libdbusmenu-16.04.0
	>=virtual/jdk-1.8
	>=x11-libs/libxkbcommon-0.5.0"
RDEPEND="${DEPEND}"

src_configure() {
	sed -i \
		-e "/JAVADIR/{s/java/${PN}\/lib/}" \
		lib/config.h.in

	sed -i \
		-e "/--add-exports/d" \
		java/CMakeLists.txt

	local mycmakeargs=(
		-DENABLE_JAYATANA=ON
		-DSTANDALONE=OFF
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	rm -rf "${ED%/}"/usr/share/java || die
	java-pkg_dojar "${BUILD_DIR}"/java/"${PN}".jar "${BUILD_DIR}"/java/"${PN}"ag.jar

	if use system-wide; then
		exeinto /etc/X11/xinit/xinitrc.d
		doexe "${FILESDIR}"/90jayatana
		sed -i \
			-e "s:JAVA_AGENT:${JAVA_PKG_JARDEST}/${PN}ag.jar:" \
			"${ED%/}"/etc/X11/xinit/xinitrc.d/90jayatana
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
