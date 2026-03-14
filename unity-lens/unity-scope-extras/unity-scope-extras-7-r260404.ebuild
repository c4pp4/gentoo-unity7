# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..14} )

UVER=
UREV=

inherit distutils-r1 ubuntu-versionator

DESCRIPTION="Online scopes for the Unity Dash"
HOMEPAGE="https://launchpad.net/onehundredscopes"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="test"

RDEPEND="
	dev-libs/dee:0=
	dev-libs/gobject-introspection
	dev-libs/libunity:0=

	$(python_gen_cond_dep '
		dev-python/pygobject:3[${PYTHON_USEDEP}]
	')
"
BDEPEND="virtual/pkgconfig"

## Neat and efficient way of bundling and tracking all available scopes into one ebuild ##
## Borrowed from chenxiaolong's Unity-for-Arch overlay at https://github.com/chenxiaolong/Unity-for-Arch ##
setvar() {
	eval "_uver_${1}=${2}"
	eval "_urev_${1}=${3}"
	eval "_use_${1}=${4}"
	eval "_dep_${1}=\"${5}\""
	packages+=( ${1} )
}
setvar audacious		0.1+13.10.20130927.1	0ubuntu1 + "$(python_gen_cond_dep 'dev-python/dbus-python[${PYTHON_USEDEP}]')"	## works with audacious 3.9
setvar calculator		0.1+14.04.20140328	0ubuntu6 + ""									## works with gnome-calculator 3.32
setvar chromiumbookmarks	0.1+13.10.20130723	0ubuntu1 + ""									## works with chromium 79 (fixed by patch)
setvar devhelp			0.1+14.04.20140328	0ubuntu5 - "$(python_gen_cond_dep 'dev-python/lxml[${PYTHON_USEDEP}]')"		## works
setvar firefoxbookmarks		0.1+13.10.20130809.1	0ubuntu1 + ""									## works with firefox 72 (fixed by patch)
setvar manpages			3.0+14.04.20140324	0ubuntu5 - "sys-apps/man-db x11-libs/gtk+:3"					## works
setvar texdoc			0.1+14.04.20140328	0ubuntu1 - ""									## works
setvar virtualbox		0.1+13.10.20130723	0ubuntu4 - ""									## works

UURL="${UURL%/*}"; SRC_URI=""
for i in ${packages[@]}; do
	unset _urev
	eval "_name=${i}; _uver=\${_uver_${i}}; _urev=\${_urev_${i}}; _use=\${_use_${i}}; _dep=\${_dep_${i}}"
	[[ -n ${_dep} ]] && RDEPEND+=" ${_name}? ( ${_dep} )"
	IUSE+="${_use/-}${_name} "
	SRC_URI+="${_name}? (
		${UURL}/unity-scope-${_name}_${_uver}.orig.tar.gz
		${UURL}/unity-scope-${_name}_${_uver}-${_urev}.diff.gz ) "
done

DEPEND="${RDEPEND}
	$(python_gen_cond_dep '
		dev-python/python-distutils-extra[${PYTHON_USEDEP}]
	')
"
PDEPEND="audacious? ( unity-lens/unity-lens-meta[music] )"

S="${WORKDIR}"

src_prepare() {
	ubuntu-versionator_src_prepare

	for i in ${packages[@]}; do
		use ${i} || continue
		eval "_name=${i}; _uver=\${_uver_${i}}; _urev=\${_urev_${i}}"
		pushd "${S}/unity-scope-${_name}-${_uver}" >/dev/null || die
			echo "$(tput bold)>>> Processing Ubuntu diff file$(tput sgr0) ..."
			eapply "${S}/unity-scope-${_name}_${_uver}-${_urev}.diff"
			echo "$(tput bold)>>> Done.$(tput sgr0)"
			[[ -f ${FILESDIR}/${i}.patch ]] && eapply "${FILESDIR}/${i}.patch"
			distutils-r1_src_prepare
		popd >/dev/null || die
	done
}

src_compile() {
	for i in ${packages[@]}; do
		use ${i} || continue
		eval "_name=${i}; _uver=\${_uver_${i}}"
		pushd "${S}/unity-scope-${_name}-${_uver}" >/dev/null || die
			BUILD_DIR="${S}/unity-scope-${_name}-${_uver}" _DISTUTILS_PREVIOUS_SITE="" distutils-r1_src_compile
		popd >/dev/null || die
	done
}

src_install() {
	for i in ${packages[@]}; do
		use ${i} || continue
		eval "_name=${i}; _uver=\${_uver_${i}}"
		pushd "${S}/unity-scope-${_name}-${_uver}" >/dev/null || die
			BUILD_DIR="${S}/unity-scope-${_name}-${_uver}" distutils-r1_src_install

			insinto /usr/share/doc/"${PF}"/unity-scope-${_name}-${_uver}
			local x
			for x in debian/changelog debian/copyright; do
				if [[ -s ${x} ]]; then
					doins "${x}"
				fi
			done
		popd >/dev/null || die
	done
}

pkg_postinst() {
	ubuntu-versionator_pkg_postinst

	local ylp dvh tlc

	has_version "gnome-extra/yelp" || ylp="to install gnome-extra/yelp package and "
	has_version "dev-util/devhelp" || dvh="to install dev-util/devhelp package and "
	tlc="${dvh}"
	has_version "app-text/texlive-core[doc]" \
		&& tlc="${tlc/ and /.}" \
		|| tlc="${tlc}to install app-text/texlive-core[doc] package."

	echo
	use audacious && ! has_version "media-sound/audacious" && elog "audacious scope needs to install media-sound/audacious package." && echo
	use calculator && ! has_version "gnome-extra/gnome-calculator" && elog "calculator scope needs to install gnome-extra/gnome-calculator." && echo
	use chromiumbookmarks && ! has_version "www-client/chromium" && elog "chromiumbookmarks scope needs to install www-client/chromium package." && echo
	use devhelp && [[ -n ${dvh} ]] && elog "devhelp scope needs ${dvh/ and /.}" && echo
	use firefoxbookmarks && ! has_version "www-client/firefox" && elog "firefoxbookmarks scope needs to install www-client/firefox package." && echo
	use manpages && elog "manpages scope needs ${ylp}to run 'mandb' command to create or update the manual page index caches." && echo
	use texdoc && [[ -n ${tlc} ]] && elog "texdoc scope needs ${tlc}" && echo
	use virtualbox && ! has_version "app-emulation/virtualbox" && elog "virtualbox scope needs to install app-emulation/virtualbox package." && echo
}
