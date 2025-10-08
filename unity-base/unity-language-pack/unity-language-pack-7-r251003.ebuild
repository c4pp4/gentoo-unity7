# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=

inherit ubuntu-versionator

DESCRIPTION="Language translations pack for Unity7 user interface"
HOMEPAGE="https://translations.launchpad.net/ubuntu"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

setvar() {
	eval "${1//-/_}=( ${2} ${3} ${4} )"
}

#[fnc] [L10N]		[pack]         [pack-gnome]   [ubuntu tag]
setvar af		25.10+20251003 25.10+20251003
setvar am		25.04+20250122 25.04+20250122
setvar an		25.04+20250122 25.04+20250122
setvar ar		25.10+20251003 25.10+20251003
setvar as		25.10+20251003 25.10+20251003
setvar ast		25.10+20251003 25.10+20251003
setvar az		25.04+20250122 25.04+20250122
setvar be		25.10+20251003 25.10+20251003
setvar bg		25.10+20251003 25.10+20251003
setvar bn		25.10+20251003 25.10+20251003
setvar bo		14.10+20140909 14.10+20140909
setvar br		25.04+20250122 25.04+20250122
setvar bs		25.10+20251003 25.10+20251003
setvar ca		25.10+20251003 25.10+20251003
setvar ca-valencia	25.10+20251003 25.10+20251003 ca
setvar ckb		25.10+20251003 25.10+20251003
setvar cs		25.10+20251003 25.10+20251003
setvar cy		25.04+20250122 25.04+20250122
setvar da		25.10+20251003 25.10+20251003
setvar de		25.10+20251003 25.10+20251003
setvar dv		14.04+20150804 14.04+20150804
setvar dz		25.04+20250122 25.04+20250122
setvar el		25.10+20251003 25.10+20251003
setvar en		25.10+20251003 25.10+20251003
setvar eo		25.10+20251003 25.10+20251003
setvar es		25.10+20251003 25.10+20251003
setvar et		25.10+20251003 25.10+20251003
setvar eu		25.10+20251003 25.10+20251003
setvar fa		25.10+20251003 25.10+20251003
setvar ff		14.04+20150804 14.04+20150804
setvar fi		25.10+20251003 25.10+20251003
setvar fil		14.04+20150804 14.04+20150804
setvar fo		14.04+20150804 14.04+20150804
setvar fr		25.10+20251003 25.10+20251003
setvar fur		25.10+20251003 25.10+20251003
setvar fy		14.04+20150804 14.04+20150804
setvar ga		25.04+20250122 25.04+20250122
setvar gd		25.10+20251003 25.10+20251003
setvar gl		25.10+20251003 25.10+20251003
setvar gu		25.10+20251003 25.10+20251003
setvar he		25.10+20251003 25.10+20251003
setvar hi		25.10+20251003 25.10+20251003
setvar hr		25.10+20251003 25.10+20251003
setvar ht		14.04+20150804 14.04+20150804
setvar hu		25.10+20251003 25.10+20251003
setvar hy		14.04+20150804 14.04+20150804
setvar ia		25.04+20250122 25.04+20250122
setvar id		25.10+20251003 25.10+20251003
setvar is		25.10+20251003 25.10+20251003
setvar it		25.10+20251003 25.10+20251003
setvar ja		25.10+20251003 25.10+20251003
setvar ka		25.10+20251003 25.10+20251003
setvar kab		25.10+20251003 25.10+20251003
setvar kk		25.10+20251003 25.10+20251003
setvar km		25.10+20251003 25.10+20251003
setvar kn		25.10+20251003 25.10+20251003
setvar ko		25.10+20251003 25.10+20251003
setvar ks		14.04+20150804 14.04+20150804
setvar ku		25.04+20250122 25.04+20250122
setvar ky		14.04+20150804 14.04+20150804
setvar lb		14.04+20150804 14.04+20150804
setvar lo		14.04+20150804 14.04+20150804
setvar lt		25.10+20251003 25.10+20251003
setvar lv		25.10+20251003 25.10+20251003
setvar mai		18.04+20180423 18.04+20180423
setvar mi		14.04+20150804 14.04+20150804
setvar mk		25.04+20250122 25.04+20250122
setvar ml		25.10+20251003 25.10+20251003
setvar mn		16.04+20160214 16.04+20160214
setvar mr		25.10+20251003 25.10+20251003
setvar ms		25.10+20251003 25.10+20251003
setvar mt		14.04+20150804 14.04+20150804
setvar my		25.10+20251003 25.10+20251003
setvar nb		25.10+20251003 25.10+20251003
setvar ne		25.10+20251003 25.10+20251003
setvar nl		25.10+20251003 25.10+20251003
setvar nn		25.10+20251003 25.10+20251003
setvar nso		14.04+20150804 14.04+20150804
setvar oc		25.10+20251003 25.10+20251003
setvar om		14.04+20150804 14.04+20150804
setvar or		25.10+20251003 25.10+20251003
setvar pa		25.10+20251003 25.10+20251003
setvar pl		25.10+20251003 25.10+20251003
setvar ps		14.04+20150804 14.04+20150804
setvar pt		25.10+20251003 25.10+20251003
setvar pt-BR		25.10+20251003 25.10+20251003 pt
setvar ro		25.10+20251003 25.10+20251003
setvar ru		25.10+20251003 25.10+20251003
setvar rw		14.04+20150804 14.04+20150804
setvar sa		14.04+20150804 14.04+20150804
setvar sc		14.04+20150804 14.04+20150804
setvar sd		14.04+20150804 14.04+20150804
setvar si		25.04+20250122 25.04+20250122
setvar sk		25.10+20251003 25.10+20251003
setvar sl		25.10+20251003 25.10+20251003
setvar so		14.04+20150804 13.04+20130418
setvar sq		25.10+20251003 25.10+20251003
setvar sr		25.10+20251003 25.10+20251003
setvar sr-Latn		25.10+20251003 25.10+20251003 sr
setvar st		14.04+20150804 14.04+20150804
setvar sv		25.10+20251003 25.10+20251003
setvar sw		14.04+20150804 14.04+20150804
setvar szl		25.04+20250122 25.04+20250122
setvar ta		25.10+20251003 25.10+20251003
setvar te		25.10+20251003 25.10+20251003
setvar tg		25.04+20250122 25.04+20250122
setvar th		25.10+20251003 25.10+20251003
setvar ti		14.04+20150804 14.04+20150804
setvar tk		14.04+20150804 14.04+20150804
setvar tl		14.04+20150804 14.04+20150804
setvar tr		25.10+20251003 25.10+20251003
setvar ts		14.04+20150804 14.04+20150804
setvar tt		14.04+20150804 14.04+20150804
setvar ug		25.10+20251003 25.10+20251003
setvar uk		25.10+20251003 25.10+20251003
setvar ur		14.04+20150804 14.04+20150804
setvar uz		16.04+20160214 16.04+20160214
setvar ve		14.04+20150804 14.04+20150804
setvar vi		25.10+20251003 25.10+20251003
setvar xh		25.04+20250122 25.04+20250122
setvar yi		14.04+20150804 14.04+20150804
setvar yo		14.04+20150804 14.04+20150804
setvar zh-CN		25.10+20251003 25.10+20251003 zh-hans
setvar zh-TW		25.10+20251003 25.10+20251003 zh-hant
setvar zu		14.04+20150804 14.04+20150804
# Add a new line and launch 'gentoo-unity-ver -u' #
#setvar [xy]		none none

# Only valid IETF language tags that are listed in #
# $(portageq get_repo_path / gentoo)/profiles/desc/l10n.desc are supported: #
MY_L10N="af am an ar as ast az be bg bn bo br bs ca ca-valencia ckb cs
cy da de dv dz el en eo es et eu fa ff fi fil fo fr fur fy ga gd gl gu
he hi hr ht hu hy ia id is it ja ka kab kk km kn ko ks ku ky lb lo lt lv
mai mi mk ml mn mr ms mt my nb ne nl nn nso oc om or pa pl ps pt pt-BR
ro ru rw sa sc sd si sk sl so sq sr sr-Latn st sv sw szl ta te tg th ti
tk tl tr ts tt ug uk ur uz ve vi xh yi yo zh-CN zh-TW zu"

UURL="${UURL%/*}"; SRC_URI=""
for flag in ${MY_L10N}; do
	flag=${flag/-/_}
	eval "tag=\${$flag[2]}"
	[[ -z ${tag} ]] && tag=${flag}
	eval "ver=\${$flag[0]}"
	eval "ver_gnome=\${$flag[1]}"
	[[ ${ver//[!0-9]} -lt 161000000000 ]] && compress="gz" || compress="xz"
	flag=${flag/_/-}
	if [[ ${flag} == "en" ]]; then
		SRC_URI+="${UURL}/language-pack-${tag}-base_${ver}.tar.${compress}
			${UURL}/language-pack-gnome-${tag}-base_${ver_gnome}.tar.${compress} "
	else
		IUSE+=" l10n_${flag}"
		SRC_URI+="l10n_${flag}? (
			${UURL}/language-pack-${tag}-base_${ver}.tar.${compress}
			${UURL}/language-pack-gnome-${tag}-base_${ver_gnome}.tar.${compress} ) "
	fi
done

RESTRICT="test"

BDEPEND="sys-devel/gettext"

S="${WORKDIR}"

src_install() {
	# Documentation
	mv language-pack-en-base/COPYING .
	default

	# sharing panel msgids
	local -a sh_msgids=(
		"No networks selected for sharing"
		"service is disabled"
		"service is enabled"
		"service is active"
		"Choose a Folder"
		"File Sharing allows you to share your Public folder with others on your "
		"When remote login is enabled, remote users can connect using the Secure "
		"Screen sharing allows remote users to view or control your screen by "
		"Copy"
		"Sharing"
		"_Computer Name"
		"_File Sharing"
		"_Screen Sharing"
		"_Media Sharing"
		"_Remote Login"
		"Some services are disabled because of no network access."
		"File Sharing"
		"_Require Password"
		"Remote Login"
		"Screen Sharing"
		"_Allow connections to control the screen"
		"_Password:"
		"_Show Password"
		"Access Options"
		"_New connections must ask for access"
		"_Require a password"
		"Media Sharing"
		"Share music, photos and videos over the network."
		"Folders"
		"Control what you want to share with others"
		"share;sharing;ssh;host;name;remote;desktop;media;audio;video;pictures;photos;"
		"Networks"
		"Enable or disable remote login"
		"Authentication is required to enable or disable remote login"
	)

	# network panel msgids
	local -a net_msgids=(
		"802.1x _Security"
		"Security"
		"Preserve"
		"Permanent"
		"Random"
		"Stable"
		"The MAC address entered here will be used as hardware address for the "
		"Profile %d"
		"WPA3"
		"Enhanced Open"
		"WPA2"
		"Enterprise"
		"%d Mb/s (%1.1f GHz)"
		"2.4 GHz / 5 GHz"
		"2.4 GHz"
		"5 GHz"
		"None"
		"Weak"
		"Ok"
		"Good"
		"Excellent"
		"Forget Connection"
		"Remove Connection Profile"
		"Remove VPN"
		"Details"
		"automatic"
		"Identity"
		"Delete Address"
		"Delete Route"
		"IPv4"
		"IPv6"
		"None"
		"WEP 40/128-bit Key (Hex or ASCII)"
		"WEP 128-bit Passphrase"
		"LEAP"
		"Dynamic WEP (802.1x)"
		"WPA & WPA2 Personal"
		"WPA & WPA2 Enterprise"
		"WPA3 Personal"
		"Signal Strength"
		"Link speed"
		"Supported Frequencies"
		"Last Used"
		"Connect _automatically"
		"Make available to _other users"
		"_Metered connection: has data limits or can incur charges"
		"Software updates and other large downloads will not be started automatically."
		"_Name"
		"_MAC Address"
		"M_TU"
		"_Cloned Address"
		"bytes"
		"IPv_4 Method"
		"Automatic (DHCP)"
		"Link-Local Only"
		"Disable"
		"Shared to other computers"
		"Addresses"
		"Netmask"
		"Gateway"
		"Automatic DNS"
		"Separate IP addresses with commas"
		"Routes"
		"Automatic Routes"
		"Metric"
		"Use this connection _only for resources on its network"
		"IPv_6 Method"
		"Automatic, DHCP only"
		"Prefix"
		"Unable to open connection editor"
		"New Profile"
		"Import from file…"
		"Add VPN"
		"S_ecurity"
		"Cannot import VPN connection"
		"The file “%s” could not be read or does not contain recognized VPN "
		"Select file to import"
		"A file named “%s” already exists."
		"_Replace"
		"Do you want to replace %s with the VPN connection you are saving?"
		"Cannot export VPN connection"
		"The VPN connection “%s” could not be exported to %s.\n"
		"Export VPN connection"
		"(Error: unable to load VPN connection editor)"
		"_SSID"
		"_BSSID"
		"undefined error in 802.1X security (wpa-eap)"
		"no file selected"
		"unspecified error validating eap-method file"
		"DER, PEM, or PKCS#12 private keys (*.der, *.pem, *.p12, *.key)"
		"DER or PEM certificates (*.der, *.pem, *.crt, *.cer)"
		"missing EAP-FAST PAC file"
		"Choose a PAC file"
		"PAC files (*.pac)"
		"GTC"
		"MSCHAPv2"
		"Anonymous"
		"Authenticated"
		"Both"
		"Anony_mous identity"
		"PAC _file"
		"_Inner authentication"
		"Allow automatic PAC pro_visioning"
		"missing EAP-LEAP username"
		"missing EAP-LEAP password"
		"Sho_w password"
		"invalid EAP-PEAP CA certificate: %s"
		"invalid EAP-PEAP CA certificate: no certificate specified"
		"Choose a Certificate Authority certificate"
		"MD5"
		"Version 0"
		"Version 1"
		"C_A certificate"
		"No CA certificate is _required"
		"PEAP _version"
		"missing EAP username"
		"missing EAP password"
		"missing EAP-TLS identity"
		"invalid EAP-TLS CA certificate: %s"
		"invalid EAP-TLS CA certificate: no certificate specified"
		"invalid EAP-TLS private-key: %s"
		"invalid EAP-TLS user-certificate: %s"
		"Unencrypted private keys are insecure"
		"The selected private key does not appear to be protected by a password. This "
		"Choose your personal certificate"
		"Choose your private key"
		"I_dentity"
		"_User certificate"
		"Private _key"
		"_Private key password"
		"invalid EAP-TTLS CA certificate: %s"
		"invalid EAP-TTLS CA certificate: no certificate specified"
		"PAP"
		"MSCHAP"
		"MSCHAPv2 (no EAP)"
		"CHAP"
		"Unknown error validating 802.1X security"
		"TLS"
		"PWD"
		"FAST"
		"Tunneled TLS"
		"Protected EAP (PEAP)"
		"Au_thentication"
		"missing leap-username"
		"missing leap-password"
		"Wi-Fi password is missing."
		"_Type"
		"missing wep-key"
		"invalid wep-key: key with a length of %zu must contain only hex-digits"
		"invalid wep-key: key with a length of %zu must contain only ascii characters"
		"invalid wep-key: wrong key length %zu. A key must be either of length 5/13 "
		"invalid wep-key: passphrase must be non-empty"
		"invalid wep-key: passphrase must be shorter than 64 characters"
		"1 (Default)"
		"Open System"
		"Shared Key"
		"_Key"
		"Sho_w key"
		"WEP inde_x"
		"invalid wpa-psk: invalid key-length %zu. Must be [8,63] bytes or 64 hex "
		"invalid wpa-psk: cannot interpret key with 64 bytes as hex"
	)

	# gnome-session-properties msgids
	local -a gs_msgids=(
		"Select Command"
		"Add Startup Program"
		"Edit Startup Program"
		"The startup command cannot be empty"
		"The startup command is not valid"
		"Enabled"
		"Icon"
		"Program"
		"Startup Applications Preferences"
		"No name"
		"No description"
		"Version of this application"
		"Could not display help document"
		"Startup Applications"
		"Choose what applications to start when you log in"
		"Additional startup _programs:"
		"_Automatically remember running applications when logging out"
		"_Remember Currently Running Applications"
		"Browse…"
		"Comm_ent:"
		"Co_mmand:"
		"_Name:"
	)

	# langselector panel msgids
	local -a ls1_msgids=(
		"Login _Screen"
		"_Language"
		"_Formats"
		"Login settings are used by all users when logging into the system"
		"Your session needs to be restarted for changes to take effect"
		"Restart Now"
		"Formats"
		"_Done"
		"_Cancel"
		"Preview"
		"Dates"
		"Times"
		"Dates & Times"
		"Numbers"
		"Measurement"
		"Paper"
		"measurement format"
		"More…"
		"No languages found"
		"No regions found"
	)
	local -a ls2_msgids=(
		"Language Support"
		"Configure multiple and native language support on your system"
	)

	# online-accounts desktop launcher msgids
	local -a oa_msgids=(
		"Online Accounts"
		"Connect to your online accounts and decide what to use them for"
	)

	# Unity help desktop launcher msgids
	local -a is_msgids=(
		"Unity Help"
		"Get help with Unity"
	)

	local \
		pofile msgid x \
		u_po="unity.po" \
		ul_po="unity.legacy" \
		ucc_po="unity-control-center.po" \
		uccl_po="unity-control-center.legacy" \
		gccl_po="gnome-control-center-2.0.legacy" \
		gs_po="gnome-session.po" \
		gsl_po="gnome-session.legacy" \
		ls_po="language-selector.po" \
		is_po="indicator-session.po" \
		ylp_po="yelp.po" \
		newline=$'\n'

	# Remove all translations except those we need
	find "${S}" -type f \
		! -name 'indicator-*' \
		! -name ${ls_po} \
		! -name 'libdbusmenu.po' \
		! -name 'ubuntu-help.po' \
		! -name 'unity*' \
		! -name ${ylp_po} \
			-delete || die
	find "${S}" -mindepth 1 -type d -empty -delete || die

	prepare_translations() {
		unpack "${FILESDIR}"/"$1".tar.xz 1>/dev/null

		for x in "${S}"/language-pack-gnome-*-base/data/*; do
			cp "${S}"/po/"${x##*data/}".po "${x}"/LC_MESSAGES/"$2" 2>/dev/null
		done
		rm -r "${S}"/po 2>/dev/null
	}

	process_msgids() {
		local src pofile

		src="$1"; shift
		pofile="$1"; shift
		if [[ -e ${src} ]] && [[ -e ${pofile} ]]; then
			for msgid in "$@"; do
				if ! grep -Fq "^\(msgid\|msgctxt\)\s\"${msgid}\"$" "${pofile}"; then
					msgid="$(awk "/^(msgid\s|msgctxt\s|)\"${msgid}\"\$/ { p = 1 } p { print } /^\$/ { p = 0 }" "${src}" 2>/dev/null)"
					case ${msgid:0:1} in
						m)
							echo "${msgid}" >> "${pofile}"
							;;
						\")
							echo "msgid \"\"${newline}${msgid}" >> "${pofile}"
							;;
					esac
				fi
			done
			msguniq --use-first -o "${pofile}" "${pofile}" 2>/dev/null
			rm "${src}" 2>/dev/null
		fi
	}

	merge_translations() {
		if [[ -f $1 ]]; then
			sed -i -e '/msgid \"\"/,/^$/d' "$1"
			cat "$1" >> "$2"
			msguniq --use-first -o "$2" "$2" 2>/dev/null
			rm "$1"
		fi
	}

	prepare_translations "activity-log-manager-translations-artful" "activity-log-manager.po"
	prepare_translations "session-shortcuts-translations-artful" "session-shortcuts.po"
	prepare_translations "unity-translations-kinetic" "${ul_po}"
	prepare_translations "unity-control-center-translations-kinetic" "${uccl_po}"
	prepare_translations "gnome-control-center-2.0-translations-jammy" "${gccl_po}"
	prepare_translations "gnome-session-translations-questing" "${gs_po}"
	prepare_translations "gnome-session-translations-xenial" "${gsl_po}"

	_progress_counter=0
	_progress_indicator() {
		local -a arr=( "|" "/" "-" "\\" )

		[[ ${_progress_counter} -eq 4 ]] && _progress_counter=0
		printf "\b\b %s" "${arr[${_progress_counter}]}"
		_progress_counter=$((_progress_counter + 1))
	}

	printf "%s  " "Processing translation files"
	_progress_indicator

	ls1_msgids+=("${sh_msgids[@]}" "${net_msgids[@]}" "${oa_msgids[@]}")

	for pofile in $( \
		find "${S}" -type f \
			\( -name "*.po" \
			-o -name "${gsl_po}" \) \
			! -name "${ls_po}" \
			! -name "${ylp_po}" \
	); do
		if [[ ${pofile##*/} == ${ucc_po} ]]; then
			_progress_indicator

			# Merge legacy translations
			x="${pofile/${ucc_po}/${uccl_po}}"
			merge_translations "${x}" "${pofile}"

			# Add translations for langselector, sharing panel, network panel and online-accounts desktop launcher
			sed -i -e "/\"Sharing\"/,+1 d" "${pofile}" || die # remove old identical msgid
			process_msgids "${pofile/${ucc_po}/${gccl_po}}" "${pofile}" "${ls1_msgids[@]}"

			_progress_indicator

			# Add translations for langselector panel
			x=${pofile/${ucc_po}/${ls_po}}
			x=${x/gnome-}
			process_msgids "${x}" "${pofile}" "${ls2_msgids[@]}"
		fi

		# Add translations for gnome-session-properties
		if [[ ${pofile##*/} == ${gs_po} ]]; then
			_progress_indicator

			process_msgids "${pofile/${gs_po}/${gsl_po}}" "${pofile}" "${gs_msgids[@]}"
			[[ -e ${pofile} ]] || continue
		fi
		if [[ ${pofile##*/} == ${gsl_po} ]]; then
			_progress_indicator

			process_msgids "${pofile}" "${pofile/${gsl_po}/${gs_po}}" "${gs_msgids[@]}"
			if [[ -e ${pofile} ]]; then
				mv "${pofile}" "${pofile/${gsl_po}/${gs_po}}"
				pofile="${pofile/${gsl_po}/${gs_po}}"
			else
				continue
			fi
		fi

		# Add translations for Unity help desktop launcher
		x=${pofile/${is_po}/${ylp_po}}
		if [[ ${pofile##*/} == ${is_po} ]] && [[ -e ${x} ]]; then
			_progress_indicator

			sed -i -e "s/GNOME/Unity/g" "${x}" || die
			process_msgids "${x}" "${pofile}" "${is_msgids[@]}"
		fi

		# Process translations for Unity
		if [[ ${pofile##*/} == ${u_po} ]]; then
			_progress_indicator

			# Merge legacy translations
			x="${pofile/${u_po}/${ul_po}}"
			merge_translations "${x}" "${pofile}"

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

	insinto /usr/share/locale
	doins -r "${S}"/language-pack-*-base/data/*

	printf "\b\b%s\n" "... done!"
}
