# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

COMMIT="f16187ed0ea0763af1e6d6a3245afc8e"

inherit java-pkg-2 meson

DESCRIPTION="Global menu for Java applications"
HOMEPAGE="https://gitlab.com/vala-panel-project/vala-panel-appmenu/tree/master/subprojects/jayatana"
SRC_URI="https://gitlab.com/vala-panel-project/vala-panel-appmenu/uploads/${COMMIT}/${P}.tar.xz"

LICENSE="MIT"
SLOT="25"
KEYWORDS="amd64"
IUSE="system-wide"
RESTRICT="mirror test"

RDEPEND="
	>=dev-libs/glib-2.40.0:2
	>=dev-libs/libdbusmenu-16.04.0
	virtual/jdk:${SLOT}
	>=x11-libs/libxkbcommon-0.5.0
"
DEPEND="${RDEPEND}

	system-wide? (
		!dev-java/jayatana:8[system-wide]
		!dev-java/jayatana:11[system-wide]
		!dev-java/jayatana:17[system-wide]
		!dev-java/jayatana:21[system-wide]
	)
"

S="${WORKDIR}/${PN}-24.02"

src_prepare() {
	java-pkg-2_src_prepare

	# Fix .jar dir #
	sed -i \
		-e "/java_install_path =/{s:'java':'${PN}-${SLOT}/lib':}" \
		java/meson.build || die

	sed -i \
		-e "s:/jayatana/:/jayatana-${SLOT}/:" \
		java/com/jarego/jayatana/{Agent.java.in,basic/NativeLibraries.java.in} || die

	sed -i \
		-e "/LIBDIR/{s/jayatana/jayatana-${SLOT}/}" \
		-e "/@CMAKE_INSTALL_FULL_DATAROOTDIR@/{s:java:${PN}-${SLOT}/lib:}" \
		lib/config.h.in || die

	sed -i \
		-e "/libdir/{s/jayatana/jayatana-${SLOT}/}" \
		lib/meson.build || die
}

src_install() {
	DOCS=(
		AUTHORS
		LICENSE
		README.md
	)
	meson_src_install

	java-pkg_regjar "${ED}"/usr/share/"${PN}-${SLOT}"/lib/*.jar

	if use system-wide; then
		exeinto /etc/X11/xinit/xinitrc.d
		sed "s:JAGDEST:${JAVA_PKG_JARDEST}:" "${FILESDIR}"/90jayatana > 90jayatana
		doexe 90jayatana
	fi
}

pkg_postinst() {
	if ! use system-wide; then
		echo
		elog "Enabling Jayatana for Java ${SLOT}"
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
