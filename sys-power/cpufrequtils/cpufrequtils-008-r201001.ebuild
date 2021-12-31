# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

UVER=""
UREV="2"

inherit systemd ubuntu-versionator

DESCRIPTION="Userspace utilities for the Linux kernel cpufreq subsystem"
HOMEPAGE="http://www.kernel.org/pub/linux/utils/kernel/cpufreq/cpufrequtils.html"
SRC_URI="${UURL}.orig.tar.bz2
	${UURL}-${UREV}.debian.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="debug nls"

DEPEND="nls? ( virtual/libintl )"
RDEPEND=""

ft() { use $1 && echo true || echo false ; }

src_prepare() {
	ubuntu-versionator_src_prepare
	eapply -p0 "${FILESDIR}"/${PN}-007-build.patch
	eapply -p0 "${FILESDIR}"/${PN}-008-remove-pipe-from-CFLAGS.patch #362523
}

src_configure() {
	export DEBUG=$(ft debug) V=true NLS=$(ft nls)
	unset bindir sbindir includedir localedir confdir
	export mandir="/usr/share/man"
	export libdir="/usr/$(get_libdir)"
	export docdir="/usr/share/doc/${PF}"
}

src_compile() {
	emake \
		CC="$(tc-getCC)" \
		LD="$(tc-getCC)" \
		AR="$(tc-getAR)" \
		STRIP=: \
		RANLIB="$(tc-getRANLIB)" \
		LIBTOOL="${EPREFIX}"/usr/bin/libtool \
		INSTALL="${EPREFIX}"/usr/bin/install
}

src_install() {
	default

	exeinto /usr/libexec
	doexe "${FILESDIR}/cpufrequtils-change.sh"

	insinto /etc/sysconfig
	newins "${FILESDIR}"/${PN}-conf.d-006 ${PN}
	systemd_dounit "${FILESDIR}/cpufrequtils.service"
	newinitd "${FILESDIR}"/${PN}-init.d-007 ${PN}
	newconfd "${FILESDIR}"/${PN}-conf.d-006 ${PN}
}
