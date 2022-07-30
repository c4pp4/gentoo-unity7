# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=

inherit ubuntu-versionator

DESCRIPTION="Merge this to setup the Unity7 build environment package.{accept_keywords,env,mask,unmask,use} files"
HOMEPAGE="https://wiki.ubuntu.com/Unity"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE="dev"
RESTRICT="binchecks strip test"

PDEPEND="unity-extra/ehooks"

S="${WORKDIR}"

src_install() {
	local pfile
	for pfile in {accept_keywords,env,mask,unmask,use}; do
		dodir "/etc/portage/package.${pfile}"
		dosym -r "${REPO_ROOT}/profiles/unity-portage.p${pfile}" \
			"/etc/portage/package.${pfile}/0000_unity-portage.p${pfile}" || die
	done

	dodir "/etc/portage/env"
	dosym -r "${REPO_ROOT}/profiles/env/ehooks-network" \
		"/etc/portage/env/ehooks-network" || die

	use dev && dosym -r "${REPO_ROOT}/profiles/unity-portage-dev.paccept_keywords" \
		"/etc/portage/package.accept_keywords/0001_unity-portage-dev.paccept_keywords"
}

pkg_postinst() {
	ubuntu-versionator_pkg_postinst

	echo

	use dev && ewarn "Overlay missing keyword unmasking has been detected. Continue if you really know how broken development packages could be." && echo

	elog "If you have recently changed USE flag or set profile then you should re-run 'emerge -avuDU --with-bdeps=y @world' to catch any updates."
	echo
}
