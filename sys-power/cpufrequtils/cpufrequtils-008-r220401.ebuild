# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=2build1

inherit systemd ubuntu-versionator

DESCRIPTION="Userspace utilities for the Linux kernel cpufreq subsystem"
HOMEPAGE="https://www.kernel.org/pub/linux/utils/kernel/cpufreq/cpufrequtils.html"
SRC_URI="${UURL}.orig.tar.bz2
	${UURL}-${UREV}.debian.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE="debug nls"

RDEPEND=">=sys-libs/glibc-2.7"
DEPEND="nls? ( virtual/libintl )"

PATCHES=(
	"${FILESDIR}"/007-build.patch
	"${FILESDIR}"/008-remove-pipe-from-CFLAGS.patch #362523
)

ft() { use $1 && echo true || echo false ; }

src_configure() {
	export DEBUG=$(ft debug) V=true NLS=$(ft nls)
	unset bindir sbindir includedir localedir confdir
	export mandir="/usr/share/man"
	export libdir="/usr/$(get_libdir)"
	export docdir="/usr/share/doc/${PF}"
}

src_compile() {
	local myemakeargs=(
		CC="$(tc-getCC)"
		LD="$(tc-getCC)"
		AR="$(tc-getAR)"
		STRIP=:
		RANLIB="$(tc-getRANLIB)"
		LIBTOOL="${EPREFIX}"/usr/bin/libtool
		INSTALL="${EPREFIX}"/usr/bin/install
	)
	emake "${myemakeargs[@]}"
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
