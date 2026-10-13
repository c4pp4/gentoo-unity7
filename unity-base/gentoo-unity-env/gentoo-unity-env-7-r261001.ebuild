# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=

inherit ubuntu-versionator

DESCRIPTION="Setup the Unity7 build environment and ehooks patching system"
HOMEPAGE="https://github.com/c4pp4/gentoo-unity7"
unset SRC_URI
S="${WORKDIR}"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="amd64"
IUSE="dev"
RESTRICT="binchecks strip test"

pkg_pretend() {
	local x
	local -a files=()

	for x in package.{accept_keywords,env,mask,unmask,use} env repos.conf; do
		[[ -f ${EROOT}/etc/portage/${x} ]] && files+=( "${x}" )
	done

	if [[ -n ${files[@]} ]]; then
		eerror "The following Portage configuration files use the single-file layout:"
		for x in "${files[@]}"; do
			eerror "  ${EROOT}/etc/portage/${x}"
		done
		eerror "This package requires the directory layout (see 'man 5 portage')."
		eerror "For example, convert /etc/portage/package.use with:"
		eerror "  mv /etc/portage/package.use /etc/portage/package.use.tmp"
		eerror "  mkdir /etc/portage/package.use"
		eerror "  mv /etc/portage/package.use.tmp /etc/portage/package.use/default"
		die "Single-file Portage configuration layout detected"
	fi
}

src_install() {
	dosym -r "${REPO_ROOT}"/version_control.sh /usr/bin/gentoo-unity-ver

	local \
		repo="gentoo-unity7" \
		x

	for x in {accept_keywords,env,mask,unmask,use}; do
		dodir "/etc/portage/package.${x}"
		dosym -r "${REPO_ROOT}/profiles/${repo}.${x}" \
			"/etc/portage/package.${x}/0000_${repo}.${x}"
	done

	dodir "/etc/portage/env"
	dosym -r "${REPO_ROOT}/profiles/${repo}.conf.env" \
		"/etc/portage/env/${repo}.conf"

	dodir "/etc/portage/repos.conf"
	dosym -r "${REPO_ROOT}/profiles/${repo}.repos" \
		"/etc/portage/repos.conf/zzzz_${repo}.conf"

	dodir "/etc/portage/repo.postsync.d"
	dosym -r "${REPO_ROOT}/profiles/${repo}.postsync" \
		"/etc/portage/repo.postsync.d/${repo}"

	use dev && dosym -r "${REPO_ROOT}/profiles/${repo}-dev.accept_keywords" \
		"/etc/portage/package.accept_keywords/0001_${repo}-dev.accept_keywords"
}

pkg_postinst() {
	ubuntu-versionator_pkg_postinst

	if use dev; then
		echo
		ewarn "Overlay development packages unmasked. Continue if you really know how broken development packages could be."
		echo
	fi

	## Remove obsolete ehooks timestamps file.
	if [[ -e ${EROOT}/etc/gentoo-unity7 ]]; then
		rm -r "${EROOT}"/etc/gentoo-unity7 || die
	fi
}
