# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

UVER=""
UREV=""

inherit ubuntu-versionator

DESCRIPTION="Merge this to setup the Unity7 build environment package.{accept_keywords,env,mask,unmask,use} files"
HOMEPAGE="http://unity.ubuntu.com/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE="dev minimal"

S=${WORKDIR}

src_install() {
	local pfile
	for pfile in {accept_keywords,env,mask,unmask,use}; do
		dodir "/etc/portage/package.${pfile}"
		dosym "${REPO_ROOT}/profiles/unity-portage.p${pfile}" \
			"/etc/portage/package.${pfile}/0000_unity-portage.p${pfile}" || die
	done

	dodir "/etc/portage/env"
	dosym "${REPO_ROOT}/profiles/env/ehooks-network" \
		"/etc/portage/env/ehooks-network" || die

	use dev \
		&& dosym "${REPO_ROOT}/profiles/unity-portage-dev.paccept_keywords" \
			"/etc/portage/package.accept_keywords/0001_unity-portage-dev.paccept_keywords"

	use minimal \
		&& dosym "${REPO_ROOT}/profiles/unity-portage-minimal.puse" \
			"/etc/portage/package.use/0001_unity-portage-minimal.puse"
}

pkg_postinst() {
	ubuntu-versionator_pkg_postinst
	use dev && echo \
		&& ewarn "Overlay missing keyword unmasking has been detected. Continue if you really know how broken development packages could be."
	echo
	elog "If you have recently changed profile then you should re-run 'emerge -avuDU --with-bdeps=y @world' to catch any updates."
	echo
}
