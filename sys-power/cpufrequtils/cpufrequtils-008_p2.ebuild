# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

URELEASE="impish"
inherit eutils toolchain-funcs multilib systemd ubuntu-versionator

UVER="-${PVR_MICRO}"

DESCRIPTION="Userspace utilities for the Linux kernel cpufreq subsystem"
HOMEPAGE="http://www.kernel.org/pub/linux/utils/kernel/cpufreq/cpufrequtils.html"
SRC_URI="${UURL}/${MY_P}.orig.tar.bz2
	${UURL}/${MY_P}${UVER}.debian.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="debug nls"
RESTRICT="mirror"

DEPEND="nls? ( virtual/libintl )"
RDEPEND=""

ft() { use $1 && echo true || echo false ; }

src_prepare() {
	ubuntu-versionator_src_prepare
	epatch "${FILESDIR}"/${PN}-007-build.patch
	epatch "${FILESDIR}"/${PN}-008-remove-pipe-from-CFLAGS.patch #362523
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
	# There's no configure script, so in this case we have to use emake
	# DESTDIR="${ED}" instead of the usual econf --prefix="${EPREFIX}".
	emake DESTDIR="${ED}" install
	dodoc AUTHORS README

	exeinto /usr/libexec
	doexe "${FILESDIR}/cpufrequtils-change.sh"

	insinto /etc/sysconfig
	newins "${FILESDIR}"/${PN}-conf.d-006 ${PN}
	systemd_dounit "${FILESDIR}/cpufrequtils.service"
	newinitd "${FILESDIR}"/${PN}-init.d-007 ${PN}
	newconfd "${FILESDIR}"/${PN}-conf.d-006 ${PN}
}
