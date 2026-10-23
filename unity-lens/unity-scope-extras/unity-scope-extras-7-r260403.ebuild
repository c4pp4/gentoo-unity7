# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..15} )

UVER=
UREV=

inherit distutils-r1 ubuntu-versionator

DESCRIPTION="Extra scopes for the Unity Dash"
HOMEPAGE="https://launchpad.net/onehundredscopes"
S="${WORKDIR}/${P}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="test"

RDEPEND="
	dev-libs/dee:0=[${PYTHON_SINGLE_USEDEP}]
	dev-libs/gobject-introspection
	dev-libs/libunity:0=[${PYTHON_SINGLE_USEDEP}]

	$(python_gen_cond_dep '
		dev-python/pygobject:3[${PYTHON_USEDEP}]
	')
"
BDEPEND="
	virtual/pkgconfig
	$(python_gen_cond_dep '
		dev-python/python-distutils-extra[${PYTHON_USEDEP}]
	')
"

## Neat and efficient way of bundling and tracking all available scopes into one ebuild ##
## Borrowed from chenxiaolong's Unity-for-Arch overlay at https://github.com/chenxiaolong/Unity-for-Arch ##
setvar() {
	eval "_uver_${1}=${2}"
	eval "_urev_${1}=${3}"
	eval "_use_${1}=${4}"
	eval "_dep_${1}=\"${5}\""
	packages+=( ${1} )
}
#[fnc] [name]                   [UVER]                  [UREV]   [IUSE] [RDEPEND]                                                            [comment]
setvar audacious                0.1+13.10.20130927.1    0ubuntu1 +      "$(python_gen_cond_dep 'dev-python/dbus-python[${PYTHON_USEDEP}]')"  ## works with audacious 3.9
setvar calculator               0.1+14.04.20140328      0ubuntu6 +      ""                                                                   ## works with gnome-calculator 3.32
setvar chromiumbookmarks        0.1+13.10.20130723      0ubuntu1 +      ""                                                                   ## works with chromium 79 (fixed by patch)
setvar devhelp                  0.1+14.04.20140328      0ubuntu5 -      "$(python_gen_cond_dep 'dev-python/lxml[${PYTHON_USEDEP}]')"         ## works
setvar firefoxbookmarks         0.1+13.10.20130809.1    0ubuntu1 +      ""                                                                   ## works with firefox 72 (fixed by patch)
setvar manpages                 3.0+14.04.20140324      0ubuntu5 -      "sys-apps/man-db x11-libs/gtk+:3"                                    ## works
setvar texdoc                   0.1+14.04.20140328      0ubuntu1 -      ""                                                                   ## works
setvar virtualbox               0.1+13.10.20130723      0ubuntu4 -      ""                                                                   ## works
## Separate the columns with spaces only (no tabs) ##

UURL="${UURL%/*}"; unset SRC_URI
for i in ${packages[@]}; do
	eval "_name=${i}; _uver=\${_uver_${i}}; _urev=\${_urev_${i}}; _use=\${_use_${i}}; _dep=\${_dep_${i}}"
	[[ -n ${_dep} ]] && RDEPEND+=" ${_name}? ( ${_dep} )"
	IUSE+="${_use/-}${_name} "
	SRC_URI+="${_name}? (
		${UURL}/unity-scope-${_name}_${_uver}.orig.tar.gz
		${UURL}/unity-scope-${_name}_${_uver}-${_urev}.diff.gz ) "
done

PDEPEND="audacious? ( unity-lens/unity-lens-meta[music] )"

src_unpack() {
	# Keep distutils-r1 build directory inside WORKDIR #
	ubuntu-versionator_src_unpack
}

src_prepare() {
	ubuntu-versionator_src_prepare

	local i

	for i in ${packages[@]}; do
		use ${i} || continue
		eval "_name=${i}; _uver=\${_uver_${i}}; _urev=\${_urev_${i}}"
		pushd "${S}/unity-scope-${_name}-${_uver}" >/dev/null || die
			einfo "Applying the Ubuntu diff file for ${_name} scope"
			eapply "${S}/unity-scope-${_name}_${_uver}-${_urev}.diff"
			[[ -f ${FILESDIR}/${i}.patch ]] && eapply "${FILESDIR}/${i}.patch"

			# Don't install the scope daemon as a top-level Python module #
			sed -i "s/^setup(name=/setup(py_modules=[], packages=[], name=/" setup.py || die
		popd >/dev/null || die
	done
}

python_compile() {
	local i

	# Build all enabled scopes, each of them is a separate setup.py project #
	for i in ${packages[@]}; do
		use ${i} || continue
		eval "_name=${i}; _uver=\${_uver_${i}}"
		pushd "${S}/unity-scope-${_name}-${_uver}" >/dev/null || die
			distutils-r1_python_compile
		popd >/dev/null || die
	done
}

src_install() {
	distutils-r1_src_install

	local i

	for i in ${packages[@]}; do
		use ${i} || continue
		eval "_name=${i}; _uver=\${_uver_${i}}"
		pushd "${S}/unity-scope-${_name}-${_uver}" >/dev/null || die
			# Run the scope with the configured version of Python #
			sed -i "s:/usr/bin/python3 :${PYTHON} :" \
				"${ED}"/usr/share/dbus-1/services/unity-scope-${_name}.service || die
			grep -Fq "${PYTHON} " "${ED}"/usr/share/dbus-1/services/unity-scope-${_name}.service || die

			## Install the Ubuntu changelog and copyright files as in ubuntu-versionator.eclass.
			(
				local x
				docinto "unity-scope-${_name}-${_uver}"
				for x in changelog copyright; do
					[[ -s debian/${x} ]] && newdoc "debian/${x}" "debian.${x}"
				done
			)
		popd >/dev/null || die
	done
}

pkg_postinst() {
	ubuntu-versionator_pkg_postinst

	local note
	local -a notes

	## Add a note about packages ($@) needed by a scope ($1) that are not installed.
	scope_needs() {
		local \
			scope="$1" \
			atom

		local -a missing

		shift
		for atom in "$@"; do
			has_version "${atom}" || missing+=( "${atom}" )
		done
		[[ -n ${missing[@]} ]] && notes+=( "${scope} scope needs to install: ${missing[*]}" )
	}

	use audacious && scope_needs audacious media-sound/audacious
	use calculator && scope_needs calculator gnome-extra/gnome-calculator
	use chromiumbookmarks && scope_needs chromiumbookmarks www-client/chromium
	use devhelp && scope_needs devhelp dev-util/devhelp
	use firefoxbookmarks && ! has_version www-client/firefox-bin && scope_needs firefoxbookmarks www-client/firefox
	use texdoc && scope_needs texdoc dev-util/devhelp "app-text/texlive-core[doc]"
	use virtualbox && scope_needs virtualbox app-emulation/virtualbox
	if use manpages; then
		scope_needs manpages gnome-extra/yelp
		notes+=( "manpages scope needs to run 'mandb' command to create or update the manual page index caches." )
	fi

	## Print the notes separated by empty lines from the rest of the output.
	if [[ -n ${notes[@]} ]]; then
		echo
		for note in "${notes[@]}"; do
			elog "${note}"
		done
		echo
	fi
}
