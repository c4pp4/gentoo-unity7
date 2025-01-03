# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
GNOME2_EAUTORECONF="yes"

UVER=
UREV=

inherit gnome2 ubuntu-versionator

DESCRIPTION="Help files for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/ubuntu-docs"
SRC_URI="${UURL}.tar.xz"

LICENSE="CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="binchecks strip test"

RDEPEND="gnome-extra/yelp"
BDEPEND="
	app-text/yelp-tools
	gnome-base/gnome-common
	virtual/pkgconfig
"

# Only valid IETF language tags that are listed in #
# $(portageq get_repo_path / gentoo)/profiles/desc/l10n.desc are supported: #
MY_L10N="am ar ast az bg bo br bs ca cs da de el en-AU en-CA en-GB eo es
et eu fi fo fr gl he hi hr hu id it ja kab kk kn ko lt lv mg ms my nb ne
nl oc pl pt pt-BR ro ru si sk sl sq sr sv ta te tg th tl tr ug uk ur uz
zh-CN zh-HK zh-TW"

for use_flag in ${MY_L10N}; do
	IUSE+=" l10n_${use_flag}"
done

src_prepare() {
	pushd ubuntu-help >/dev/null || die
		local langs
		for use_flag in ${MY_L10N}; do
			use l10n_${use_flag} && langs+=" ${use_flag/-/_}"
		done

		sed -i \
			-e "/HELP_LINGUAS/a HELP_LINGUAS =${langs}" \
			-e "/addremove/d" \
			-e "/prefs-language-install.page/d" \
			Makefile.am || die

		rm it/figures/unity.png || die
		rm {de,it}/figures/unity-dash.png || die
		rm it/figures/unity-dash-intro.png || die
		rm {de,it}/figures/unity-dash-sample.png || die
		rm {de,it}/figures/unity-launcher-intro.png || die
		rm {de,it}/figures/unity-overview.png || die

		# Corrections (itstool: Segmentation fault (core dumped) #
		sed -i \
			-e "s/e gui>/e <gui>/" \
			-e "s/<em\.s/<em>s/" \
			-e "s|modul<em>|modul</em>|" \
			-e 's/"em>F/"<em>F/' \
			-e "s|edky<gui>|edky</gui>|" \
			-e "s/<Ch/<gui>Ch/" \
			cs/cs.po || die

		sed -i "s/k<gui>/k<\/gui>/" da/da.po || die

		sed -i \
			-e 's|"<key>Ctrl</key><|"<keyseq><key>Ctrl</key><|' \
			-e "s/guι/gui/" \
			el/el.po || die

		sed -i "s|ー&|ー/|" ja/ja.po || die

		sed -i \
			-e "s/<gui>Configurações do Sistema<guiseq>/<guiseq><gui>Configurações do Sistema/" \
			-e "s/ <link\././" \
			-e "s/ & / &amp; /" \
			pt/pt.po || die

		sed -i 's/"link href=\\//' ru/ru.po || die

		sed -i "s/ gui>/<gui>/" tr/tr.po || die

		sed -i \
			-e "s|<link xref=\\\\\\\||" \
			-e "s/قېتىم <link/قېتىم/" \
			-e "s|دا كۆرسەت<gui>|دا كۆرسەت</gui>|" \
			-e 's|xref=\\"shell-exit\\">چېكىنى|<link xref=\\"shell-exit\\">|' \
			-e 's|\\"#files\\\\\\"/>|<link xref=\\"#files\\"/>|' \
			-e 's|<link xref=\\\\\\"#folders\\\\\\"/>|<link xref=\\"#folders\\"/>|' \
			-e 's|\\"nautilus-behavior#executable\\\\\\\"/>|<link xref=\\"nautilus-behavior#executable\\"/>|' \
			-e "s/ app>/<app>/" \
			-e "s/ gui>/<gui>/" \
			ug/ug.po || die
	popd >/dev/null || die

	pushd ubuntu-help/C >/dev/null || die
		sed -i "s/ addremove//" index.page || die
		sed -i "/Install languages/d" prefs-language.page || die
		sed -i '/id="complex"/,+49 d' keyboard-layouts.page || die
		sed -i "/dozens of languages/,+3 d" session-language.page || die
		sed -i "/language-selector/d" session-{formats,language}.page || die
	popd >/dev/null || die

	pushd ubuntu-help/C/figures >/dev/null || die
		cp "${FILESDIR}"/gentoo_signet.png ubuntu-logo.png || die
		cp "${FILESDIR}"/unity_logo.png ubuntu-mascot-creature.png || die
		cp "${FILESDIR}"/unity.png . || die
		cp "${FILESDIR}"/unity-dash.png . || die
		cp "${FILESDIR}"/unity-dash-intro.png . || die
		cp "${FILESDIR}"/unity-dash-sample.png . || die
		cp "${FILESDIR}"/unity-launcher.png . || die
		cp "${FILESDIR}"/unity-launcher-intro.png . || die
		cp "${FILESDIR}"/unity-overview.png . || die
	popd >/dev/null || die

	local -a \
		page_files=( $(find ubuntu-help -maxdepth 2 -type f -name "*.page") ) \
		po_files

	for use_flag in ${langs# }; do
		po_files+=( "ubuntu-help/${use_flag}/${use_flag}.po" )
	done

	sed -i \
		-e "s/Ubuntu Desktop/Gentoo Unity⁷ Desktop/" \
		-e "s/Ubuntu desktop/Gentoo Unity⁷ Desktop/" \
		-e "s/Welcome to Ubuntu/Welcome to Gentoo Unity⁷/" \
		-e "s/Ubuntu features/Gentoo Unity⁷ features/" \
		-e "s/Ubuntu Button/Gentoo Button/" \
		-e "s/the Ubuntu logo/the Gentoo logo/" \
		"${page_files[@]}" "${po_files[@]}" || die

	if [[ -n ${po_files[@]} ]]; then
		sed -i ":bgn;/Unity⁷/{:loop;n;/^#/b bgn;s/Ubuntu/Gentoo Unity⁷/g;b loop;}" "${po_files[@]}" || die
		sed -i ":bgn;/Gentoo Button/{:loop;n;/^#/b bgn;s/Ubuntu/Gentoo/g;b loop;}" "${po_files[@]}" || die
		sed -i ":bgn;/the Gentoo logo/{:loop;n;/^#/b bgn;s/Ubuntu/Gentoo/g;b loop;}" "${po_files[@]}" || die
	fi

	ubuntu-versionator_src_prepare
}
