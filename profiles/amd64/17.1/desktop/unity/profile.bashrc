if [[ ${EBUILD_PHASE} == "setup" ]] ; then
	CURRENT_PROFILE="$(readlink /etc/portage/make.profile)"
	REPO_ROOT="$(/usr/bin/portageq get_repo_path / gentoo-unity7)"

	KEYWORD_STATE="${KEYWORD_STATE:=`grep ACCEPT_KEYWORDS /etc/portage/make.conf 2>/dev/null`}"
	KEYWORD_STATE="${KEYWORD_STATE:=`grep ACCEPT_KEYWORDS /etc/make.conf 2>/dev/null`}"
	if [[ -n "$(echo ${KEYWORD_STATE} | grep \~)" ]] && [[ "$(eval echo \${UNITY_GLOBAL_KEYWORD_UNMASK})" != "yes" ]]; then
			eerror "Oops! Your system has been detected as having ~arch keywords globally unmasked (${KEYWORD_STATE})."
			eerror " To maintain build sanity for Unity it is highly recommended to *NOT* globally set your entire system to experimental."
			eerror " To override this error message, set 'UNITY_GLOBAL_KEYWORD_UNMASK=yes' in make.conf and accept that many packages may fail to build or run correctly."
			eerror
			die
	fi

## ehooks patching system.
	local -a EHOOKS_SOURCE=()

	## Define function to look for ehooks in setup phase.
	pre_pkg_setup() {

	local \
		pkg \
		basedir="${REPO_ROOT}"/profiles/ehooks

	for pkg in ${CATEGORY}/{${P}-${PR},${P},${P%.*},${P%.*.*},${PN}}{:${SLOT%/*},}; do
		if [[ -d ${EHOOKS_PATH:=${basedir}}/${pkg} ]]; then
			true
		elif [[ -d ${basedir}/${pkg} ]]; then
			EHOOKS_PATH="${basedir}"
		else
			continue
		fi

		local prev_shopt=$(shopt -p nullglob)
		shopt -s nullglob
		EHOOKS_SOURCE=( "${EHOOKS_PATH}/${pkg}"/*.ehooks )
		${prev_shopt}
		break
	done

	## Process EHOOKS_SOURCE.
	if [[ -n ${EHOOKS_SOURCE[@]} ]]; then

	## Define function to check if USE flag is declared.
	ehooks_use() {
		return $(portageq has_version / unity-extra/ehooks["$1"])
	}

	## Define function to skip all related ehooks if USE flag is not declared.
	ehooks_require() {
		if ! portageq has_version / unity-extra/ehooks["$1"]; then
			echo " * USE flag '$1' not declared: skipping related ehooks..."
			exit ${SKIP_CODE}
		fi
	}

	## Define function to apply ehooks.
	__ehooks_apply() {
		local \
			x \
			log="${T}/ehooks.log" \
			color_norm=$(tput sgr0) \
			color_bold=$(tput bold) \
			color_red=$(tput setaf 1)

		## Append bug information to 'die' command.
		local \
			bugapnd="eerror \"S: '\${S}'\"" \
			bugmsg="eerror \"${color_bold}Please submit ehooks bug at ${color_norm}'https://github.com/c4pp4/gentoo-unity7/issues'.\"" \
			buglog="eerror \"${color_bold}The ehooks log is located at ${color_norm}'${log}'.\""

		source <(declare -f die | sed -e "/${bugapnd}/a ${bugmsg}" -e "/${bugapnd}/a ${buglog}")
		## End of modifying 'die' command

		if [[ ${EHOOKS_ACCEPT} != "yes" ]]; then
			eerror
			eerror "Warning!"
			eerror
			eerror "Patches from gentoo-unity7 overlay will be applied to ${CATEGORY}/${PN} and some other packages from the Gentoo tree via ehooks patching system."
			eerror "For more details, see gentoo-unity7/docs/ehooks.md - Chapter I."
			eerror "Set EHOOKS_ACCEPT=\"yes\" in make.conf to confirm you agree with it."
			eerror
			die "Acceptance needed"
		fi

		declare -F ehooks 1>"${log}"
		[[ -s ${log} ]] \
			&& die "ehooks: function name collision"

		echo "${color_red}${color_bold}>>> Loading gentoo-unity7 ehooks${color_norm} from ${EHOOKS_SOURCE[0]%/*} ..."
		for x in "${EHOOKS_SOURCE[@]}"; do

		## Process current phase.
		if [[ ${x} == *"${FUNCNAME[1]}.ehooks" ]]; then

		## Warn when ehooks file is not readable.
		[[ ! -r ${x} ]] \
			&& ewarn "${x##*/}: not readable" && continue

		source "${x}" 2>"${log}"
		[[ -s ${log} ]] \
			&& die "$(<${log})"
		declare -F ehooks 1>/dev/null \
			|| die "ehooks: function not found"
		einfo "Processing ${x##*/} ..."

		local EHOOKS_FILESDIR=${x%/*}/files

		## Check for eautoreconf.
		if [[ ${EBUILD_PHASE} == prepare ]]; then

		if declare -f ehooks | grep -q "eautoreconf"; then
			if ! declare -F eautoreconf 1>/dev/null; then
				local eautoreconf_names="eautoreconf _at_uses_pkg _at_uses_autoheader _at_uses_automake _at_uses_gettext _at_uses_glibgettext _at_uses_intltool _at_uses_gtkdoc _at_uses_gnomedoc _at_uses_libtool _at_uses_libltdl eaclocal_amflags eaclocal _elibtoolize eautoheader eautoconf eautomake autotools_env_setup autotools_run_tool ALL_AUTOTOOLS_MACROS autotools_check_macro autotools_check_macro_val _autotools_m4dir_include autotools_m4dir_include autotools_m4sysdir_include gnuconfig_findnewest elibtoolize tc-getLD tc-getPROG _tc-getPROG"

				x="$(portageq get_repo_path / gentoo)/eclass"
				local -a fn_source=(
					"${x}/autotools.eclass"
					"${x}/libtool.eclass"
					"${x}/gnuconfig.eclass"
					"${x}/toolchain-funcs.eclass"
				)

				for x in "${fn_source[@]}"; do
					[[ -f ${x} ]] \
						|| die "${x}: file not found"

					source <(awk "/^(${eautoreconf_names// /|})(\(\)|=\(\$)/ { p = 1 } p { print } /(^(}|\))|; })\$/ { p = 0 }" ${x} 2>/dev/null)
				done

				declare -F eautoreconf 1>/dev/null \
					|| die "eautoreconf: function not found"
			fi
		fi

		fi ## End of checking for eautoreconf.

		## Output information messages to fd 3 instead of stderr (issue #193).
		local msgfunc_names="einfo einfon ewarn ebegin __eend __vecho"

		for x in ${msgfunc_names}; do
			source <(declare -f ${x} | sed "s/\(1>&\)2/\13/")
		done

		## Define exit code to skip ehooks.
		local SKIP_CODE=99

		## Log errors to screen and logfile via fd 3.
		exec 3>&1
		ehooks 2>&1 >&3 | tee "${log}"

		## Clear source when exit status SKIP_CODE is returned.
		## Needs to be right after the ehooks call.
		[[ ${PIPESTATUS[0]} -eq ${SKIP_CODE} ]] && EHOOKS_SOURCE=()

		[[ -s ${log} ]] \
			&& die "$(<${log})"

		## Sanitize.
		exec 3>&-
		for x in ${msgfunc_names}; do
			source <(declare -f ${x} | sed "s/\(1>&\)3/\12/")
		done
		unset -f ehooks
		if [[ -n ${eautoreconf_names} ]]; then
			eautoreconf_names="${eautoreconf_names/ elibtoolize tc-getLD tc-getPROG _tc-getPROG}"
			for x in ${eautoreconf_names}; do
				unset ${x}
			done
		fi

		## Exit the current loop when source is cleared.
		[[ -z ${EHOOKS_SOURCE[@]} ]] && break

		fi ## End of processing current phase.

		done
		echo "${color_red}${color_bold}>>> Done.${color_norm}"

		## Sanitize 'die' command.
		source <(declare -f die | sed "/ehooks/d")

	} ## End of __ehooks_apply function.

	## Apply ehooks intended for setup phase.
	[[ ${EHOOKS_SOURCE[@]} == *"pre_pkg_setup"* ]] \
		&& __ehooks_apply
	[[ ${EHOOKS_SOURCE[@]} == *"post_pkg_setup"* ]] \
		&& post_pkg_setup() {
			__ehooks_apply
		}

	fi ## End of processing EHOOKS_SOURCE.

	} ## End of pre_pkg_setup function.

fi ## End of setup phase.

## Define appropriate ebuild function to apply ehooks.
case ${EBUILD_PHASE} in
	unpack)
		[[ ${EHOOKS_SOURCE[@]} == *"pre_src_unpack"* ]] \
			&& pre_src_unpack() {
				__ehooks_apply
			}
		[[ ${EHOOKS_SOURCE[@]} == *"post_src_unpack"* ]] \
			&& post_src_unpack() {
				__ehooks_apply
			}
		;;
	prepare)
		[[ ${EHOOKS_SOURCE[@]} == *"pre_src_prepare"* ]] \
			&& pre_src_prepare() {
				__ehooks_apply
			}
		[[ ${EHOOKS_SOURCE[@]} == *"post_src_prepare"* ]] \
			&& post_src_prepare() {
				__ehooks_apply
			}
		;;
	configure)
		[[ ${EHOOKS_SOURCE[@]} == *"pre_src_configure"* ]] \
			&& pre_src_configure() {
				__ehooks_apply
			}
		[[ ${EHOOKS_SOURCE[@]} == *"post_src_configure"* ]] \
			&& post_src_configure() {
				__ehooks_apply
			}
		;;
	compile)
		[[ ${EHOOKS_SOURCE[@]} == *"pre_src_compile"* ]] \
			&& pre_src_compile() {
				__ehooks_apply
			}
		[[ ${EHOOKS_SOURCE[@]} == *"post_src_compile"* ]] \
			&& post_src_compile() {
				__ehooks_apply
			}
		;;
	install)
		[[ ${EHOOKS_SOURCE[@]} == *"pre_src_install"* ]] \
			&& pre_src_install() {
				__ehooks_apply
			}
		[[ ${EHOOKS_SOURCE[@]} == *"post_src_install"* ]] \
			&& post_src_install() {
				__ehooks_apply
			}
		;;
	preinst)
		[[ ${EHOOKS_SOURCE[@]} == *"pre_pkg_preinst"* ]] \
			&& pre_pkg_preinst() {
				__ehooks_apply
			}
		[[ ${EHOOKS_SOURCE[@]} == *"post_pkg_preinst"* ]] \
			&& post_pkg_preinst() {
				__ehooks_apply
			}
		;;
	postinst)
		[[ ${EHOOKS_SOURCE[@]} == *"pre_pkg_postinst"* ]] \
			&& pre_pkg_postinst() {
				__ehooks_apply
			}
		[[ ${EHOOKS_SOURCE[@]} == *"post_pkg_postinst"* ]] \
			&& post_pkg_postinst() {
				__ehooks_apply
			}
		;;
esac
## End of ehooks patching system.
