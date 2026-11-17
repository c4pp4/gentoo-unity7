# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=

inherit ubuntu-versionator

DESCRIPTION="Language translations pack for Unity7 user interface"
HOMEPAGE="https://translations.launchpad.net/ubuntu"
S="${WORKDIR}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"

setvar() {
	eval "${1//-/_}=( ${2} ${3} ${4} )"
	MY_L10N+=" ${1}"
}

# Only valid IETF language tags that are listed in #
# $(portageq get_repo_path / gentoo)/profiles/desc/l10n.desc are supported: #
#[fnc] [L10N]           [pack]         [pack-gnome]   [ubuntu tag]
setvar af               26.10+20261008 26.10+20261008
setvar am               25.04+20250122 25.04+20250122
setvar an               25.04+20250122 25.04+20250122
setvar ar               26.10+20261008 26.10+20261008
setvar as               26.10+20261008 26.10+20261008
setvar ast              26.10+20261008 26.10+20261008
setvar az               25.04+20250122 25.04+20250122
setvar be               26.10+20261008 26.10+20261008
setvar bg               26.10+20261008 26.10+20261008
setvar bn               26.10+20261008 26.10+20261008
setvar bo               14.10+20140909 14.10+20140909
setvar br               25.04+20250122 25.04+20250122
setvar bs               26.10+20261008 26.10+20261008
setvar ca               26.10+20261008 26.10+20261008
setvar ca-valencia      26.10+20261008 26.10+20261008 ca
setvar ckb              26.10+20261008 26.10+20261008
setvar cs               26.10+20261008 26.10+20261008
setvar cy               25.04+20250122 25.04+20250122
setvar da               26.10+20261008 26.10+20261008
setvar de               26.10+20261008 26.10+20261008
setvar dv               14.04+20150804 14.04+20150804
setvar dz               25.04+20250122 25.04+20250122
setvar el               26.10+20261008 26.10+20261008
setvar en               26.10+20261008 26.10+20261008
setvar eo               26.10+20261008 26.10+20261008
setvar es               26.10+20261008 26.10+20261008
setvar et               26.10+20261008 26.10+20261008
setvar eu               26.10+20261008 26.10+20261008
setvar fa               26.10+20261008 26.10+20261008
setvar ff               14.04+20150804 14.04+20150804
setvar fi               26.10+20261008 26.10+20261008
setvar fil              14.04+20150804 14.04+20150804
setvar fo               14.04+20150804 14.04+20150804
setvar fr               26.10+20261008 26.10+20261008
setvar fur              26.10+20261008 26.10+20261008
setvar fy               14.04+20150804 14.04+20150804
setvar ga               25.04+20250122 25.04+20250122
setvar gd               26.10+20261008 26.10+20261008
setvar gl               26.10+20261008 26.10+20261008
setvar gu               26.10+20261008 26.10+20261008
setvar he               26.10+20261008 26.10+20261008
setvar hi               26.10+20261008 26.10+20261008
setvar hr               26.10+20261008 26.10+20261008
setvar ht               14.04+20150804 14.04+20150804
setvar hu               26.10+20261008 26.10+20261008
setvar hy               14.04+20150804 14.04+20150804
setvar ia               26.10+20261008 26.10+20261008
setvar id               26.10+20261008 26.10+20261008
setvar is               26.10+20261008 26.10+20261008
setvar it               26.10+20261008 26.10+20261008
setvar ja               26.10+20261008 26.10+20261008
setvar ka               26.10+20261008 26.10+20261008
setvar kab              26.10+20261008 26.10+20261008
setvar kk               26.10+20261008 26.10+20261008
setvar km               26.10+20261008 26.10+20261008
setvar kn               26.10+20261008 26.10+20261008
setvar ko               26.10+20261008 26.10+20261008
setvar ks               14.04+20150804 14.04+20150804
setvar ku               25.04+20250122 25.04+20250122
setvar ky               14.04+20150804 14.04+20150804
setvar lb               14.04+20150804 14.04+20150804
setvar lo               14.04+20150804 14.04+20150804
setvar lt               26.10+20261008 26.10+20261008
setvar lv               26.10+20261008 26.10+20261008
setvar mai              18.04+20180423 18.04+20180423
setvar mi               14.04+20150804 14.04+20150804
setvar mk               25.04+20250122 25.04+20250122
setvar ml               26.10+20261008 26.10+20261008
setvar mn               16.04+20160214 16.04+20160214
setvar mr               26.10+20261008 26.10+20261008
setvar ms               26.10+20261008 26.10+20261008
setvar mt               14.04+20150804 14.04+20150804
setvar my               26.10+20261008 26.10+20261008
setvar nb               26.10+20261008 26.10+20261008
setvar ne               26.10+20261008 26.10+20261008
setvar nl               26.10+20261008 26.10+20261008
setvar nn               26.10+20261008 26.10+20261008
setvar nso              14.04+20150804 14.04+20150804
setvar oc               26.10+20261008 26.10+20261008
setvar om               14.04+20150804 14.04+20150804
setvar or               26.10+20261008 26.10+20261008
setvar pa               26.10+20261008 26.10+20261008
setvar pl               26.10+20261008 26.10+20261008
setvar ps               14.04+20150804 14.04+20150804
setvar pt               26.10+20261008 26.10+20261008
setvar pt-BR            26.10+20261008 26.10+20261008 pt
setvar ro               26.10+20261008 26.10+20261008
setvar ru               26.10+20261008 26.10+20261008
setvar rw               14.04+20150804 14.04+20150804
setvar sa               14.04+20150804 14.04+20150804
setvar sc               14.04+20150804 14.04+20150804
setvar sd               14.04+20150804 14.04+20150804
setvar si               25.04+20250122 25.04+20250122
setvar sk               26.10+20261008 26.10+20261008
setvar sl               26.10+20261008 26.10+20261008
setvar so               14.04+20150804 13.04+20130418
setvar sq               26.10+20261008 26.10+20261008
setvar sr               26.10+20261008 26.10+20261008
setvar sr-Latn          26.10+20261008 26.10+20261008 sr
setvar st               14.04+20150804 14.04+20150804
setvar sv               26.10+20261008 26.10+20261008
setvar sw               14.04+20150804 14.04+20150804
setvar szl              25.04+20250122 25.04+20250122
setvar ta               26.10+20261008 26.10+20261008
setvar te               26.10+20261008 26.10+20261008
setvar tg               25.04+20250122 25.04+20250122
setvar th               26.10+20261008 26.10+20261008
setvar ti               14.04+20150804 14.04+20150804
setvar tk               14.04+20150804 14.04+20150804
setvar tl               14.04+20150804 14.04+20150804
setvar tr               26.10+20261008 26.10+20261008
setvar ts               14.04+20150804 14.04+20150804
setvar tt               14.04+20150804 14.04+20150804
setvar ug               26.10+20261008 26.10+20261008
setvar uk               26.10+20261008 26.10+20261008
setvar ur               14.04+20150804 14.04+20150804
setvar uz               16.04+20160214 16.04+20160214
setvar ve               14.04+20150804 14.04+20150804
setvar vi               26.10+20261008 26.10+20261008
setvar xh               25.04+20250122 25.04+20250122
setvar yi               14.04+20150804 14.04+20150804
setvar yo               14.04+20150804 14.04+20150804
setvar zh-CN            26.10+20261008 26.10+20261008 zh-hans
setvar zh-TW            26.10+20261008 26.10+20261008 zh-hant
setvar zu               14.04+20150804 14.04+20150804
# Separate the columns with spaces only (no tabs) #
# Add a new line and launch 'gentoo-unity-ver -u' #
#setvar xy               none none

unset SRC_URI
for flag in ${MY_L10N}; do
	flag=${flag/-/_}
	eval "tag=\${$flag[2]}"
	[[ -z ${tag} ]] && tag=${flag}
	eval "ver=\${$flag[0]}"
	eval "ver_gnome=\${$flag[1]}"
	[[ ${ver//[!0-9]} -lt 161000000000 ]] && compress="gz" || compress="xz"
	flag=${flag/_/-}
	if [[ ${flag} == "en" ]]; then
		SRC_URI+="$(uuri "language-pack-${tag}-base_${ver}.tar.${compress}" "language-pack-gnome-${tag}-base_${ver_gnome}.tar.${compress}") "
	else
		IUSE+=" l10n_${flag}"
		SRC_URI+="l10n_${flag}? (
			$(uuri "language-pack-${tag}-base_${ver}.tar.${compress}" "language-pack-gnome-${tag}-base_${ver_gnome}.tar.${compress}") ) "
	fi
done

RESTRICT="test"

BDEPEND="sys-devel/gettext"

src_install() {
	local \
		pofile x \
		u_po="unity.po" \
		ucc_po="unity-control-center.po" \
		uccn_po="unity-control-center-network.legacy" \
		uccs_po="unity-control-center-sharing.legacy" \
		uccls_po="unity-control-center-langselector.legacy" \
		is_po="indicator-session.po" \
		uhl_po="unity-help.legacy"

	# Remove all translations except those we need
	find "${S}" -type f \
		! -name 'indicator-*' \
		! -name 'libdbusmenu.po' \
		! -name 'ubuntu-help.po' \
		! -name 'unity*' \
		! -name changelog \
		! -name copyright \
			-delete || die
	find "${S}" -mindepth 1 -type d -empty -delete || die

	unpack_translations() {
		unpack "${FILESDIR}"/"$1".tar.xz 1>/dev/null

		for x in "${S}"/language-pack-gnome-*-base/data/*; do
			cp "${S}"/po/"${x##*data/}".po "${x}"/LC_MESSAGES/"$2" 2>/dev/null
		done
		rm -r "${S}"/po 2>/dev/null
	}

	merge_translations() {
		if [[ -f $1 ]]; then
			msgcat --use-first -o "$2" "$2" "$1" 2>/dev/null
			rm "$1"
		fi
	}

	unpack_translations "activity-log-manager-translations-artful" "activity-log-manager.po"
	unpack_translations "session-shortcuts-translations-artful" "session-shortcuts.po"
	unpack_translations "unity-control-center-network-translations-261117" "${uccn_po}"
	unpack_translations "unity-control-center-sharing-translations-261117" "${uccs_po}"
	unpack_translations "unity-control-center-langselector-translations-261117" "${uccls_po}"
	unpack_translations "cinnamon-session-translations-151017" "unity-session-properties.po"
	unpack_translations "indicator-appearance-translations-261017" "indicator-appearance.po"
	unpack_translations "indicator-notifications-translations-261017" "indicator-notifications.po"
	unpack_translations "mate-screenshot-translations-focal" "mate-screenshot.po" # mate-screenshot quicklist (ehooks/mate-extra/mate-utils)
	unpack_translations "unity-help-translations-261017" "${uhl_po}"

	_progress_counter=0
	_progress_indicator() {
		local -a arr=( "|" "/" "-" "\\" )

		[[ ${_progress_counter} -eq 4 ]] && _progress_counter=0
		printf "\b\b %s" "${arr[${_progress_counter}]}"
		_progress_counter=$((_progress_counter + 1))
	}

	printf "%s  " "Processing translation files"
	_progress_indicator

	for pofile in $( \
		find "${S}" -type f \
			-name "*.po" \
	); do
		if [[ ${pofile##*/} == ${ucc_po} ]]; then
			# Merge translations for langselector panel, network panel and sharing panel
			merge_translations "${pofile/${ucc_po}/${uccls_po}}" "${pofile}"
			merge_translations "${pofile/${ucc_po}/${uccn_po}}" "${pofile}"
			sed -i -e "/\"Sharing\"/,+1 d" "${pofile}" || die # remove old identical msgid
			merge_translations "${pofile/${ucc_po}/${uccs_po}}" "${pofile}"
		fi

		# Add translations for Unity help desktop launcher
		if [[ ${pofile##*/} == ${is_po} ]]; then
			merge_translations "${pofile/${is_po}/${uhl_po}}" "${pofile}"
		fi

		# Process translations for Unity
		if [[ ${pofile##*/} == ${u_po} ]]; then
			# Rename Ubuntu Desktop
			sed -i -e "s/Ubuntu Desktop/Gentoo Unity⁷ Desktop/" -e "/Unity⁷/{n;s/Ubuntu/Gentoo Unity⁷/;}" "${pofile}" || die
		fi

		msgfmt -o "${pofile%.po}.mo" "${pofile}"
		rm "${pofile}" 2>/dev/null
	done

	# Clean up the leftovers
	find "${S}" -type f \
		\( -name "*.po" \
		-o -name "*.legacy" \) \
			-delete || die
	find "${S}" -mindepth 1 -type d -empty -delete || die

	# LC_MESSAGES
	insinto /usr/share/locale
	doins -r "${S}"/language-pack-*-base/data/*

	# Documentation: install the Ubuntu changelog and copyright files as in ubuntu-versionator.eclass.
	(
		local pack y
		for pack in "${S}"/language-pack-*-base; do
			_progress_indicator
			docinto "${pack##*/}"
			for y in changelog copyright; do
				[[ -s ${pack}/debian/${y} ]] && newdoc "${pack}/debian/${y}" "debian.${y}"
			done
		done
	)

	printf "\b\b%s\n" "... done!"
}
