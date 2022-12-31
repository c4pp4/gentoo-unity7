# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{8..11} )

UVER=
UREV=

inherit distutils-r1 cmake systemd ubuntu-versionator

DESCRIPTION="Tool to migrate in user session settings used by the Unity desktop"
HOMEPAGE="https://launchpad.net/session-migration"
SRC_URI="${UURL}.tar.xz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="amd64"

DEPEND=">=dev-libs/glib-2.51.1:2"
RDEPEND="${DEPEND}
	>=sys-libs/glibc-2.4
"

distutils_enable_tests nose

src_test() {
	pushd "${BUILD_DIR}" >/dev/null || die
		nosetests tests/migration_tests.py
	popd >/dev/null || die
}

src_install() {
	cmake_src_install

	dosym -r $(systemd_get_userunitdir)/session-migration.service \
		$(systemd_get_userunitdir)/graphical-session-pre.target.wants/session-migration.service
}
