## ehooks patching system.
if [[ ${EBUILD_PHASE} == "setup" ]]; then
	## Get gentoo-unity7 repo path via portageq tool.
	PORTAGE_QUERY_TOOL=portageq
	[[ -e "${PORTAGE_BIN_PATH}"/portageq-wrapper ]] && PORTAGE_QUERY_TOOL="${PORTAGE_BIN_PATH}"/portageq-wrapper
	if "${PORTAGE_QUERY_TOOL}" get_repo_path / gentoo-unity7 >/dev/null 2>&1; then
		REPO_ROOT=$("${PORTAGE_QUERY_TOOL}" get_repo_path / gentoo-unity7)
	else
		die "portageq: gentoo-unity7 repo path not found. If you have recently updated sys-apps/portage then you should re-run 'emerge -avuDU --with-bdeps=y @world' to catch any updates."
	fi

	## Look for ehooks in setup phase.
	local \
		pkg \
		basedir="${REPO_ROOT}"/ehooks

	EHOOKS_SOURCE=()

	for pkg in generic ${CATEGORY}/{${P}-${PR},${P},${P%.*},${P%.*.*},${PN}}{:${SLOT%/*},}; do
		if [[ -d ${EHOOKS_PATH:-${basedir}}/${pkg} ]]; then
			EHOOKS_ROOT="${EHOOKS_PATH:-${basedir}}"
		elif [[ -d ${basedir}/${pkg} ]]; then
			EHOOKS_ROOT="${basedir}"
		else
			continue
		fi

		local prev_shopt=$(shopt -p nullglob)
		shopt -s nullglob
		EHOOKS_SOURCE+=( "${EHOOKS_ROOT}/${pkg}"/*.ehooks )
		${prev_shopt}
		[[ ${pkg} != "generic" ]] && break
	done

	## Define function to check if USE flag is declared.
	ehooks_use() {
		return $("${PORTAGE_QUERY_TOOL}" has_version / unity-base/gentoo-unity-env["$1"])
	}

	## Define function to skip all related ehooks if USE flag is not declared.
	ehooks_require() {
		if ! "${PORTAGE_QUERY_TOOL}" has_version / unity-base/gentoo-unity-env["$1"]; then
			echo " * USE flag '$1' not declared: skipping related ehooks..."
			exit ${SKIP_CODE}
		fi
	}

	## Define function to apply ehooks.
	ehooks_apply() {
		## Process EHOOKS_SOURCE.
		if [[ ${EHOOKS_SOURCE[@]} == *"${FUNCNAME[1]}"* ]]; then

		local \
			x \
			log="${T}/ehooks.log" \
			color_norm=$(tput sgr0) \
			color_bold=$(tput bold) \
			color_red=$(tput setaf 1)

		> "${log}"

		## Append bug information to 'die' command.
		local \
			bugapnd="eerror \"S: '\${S}'\"" \
			bugmsg="eerror \"${color_bold}Please submit ehooks bug at ${color_norm}'https://github.com/c4pp4/gentoo-unity7/issues'.\"" \
			buglog="eerror \"${color_bold}The ehooks log is located at ${color_norm}'${log}'.\""

		source <(declare -f die | sed -e "/${bugapnd}/a ${bugmsg}" -e "/${bugapnd}/a ${buglog}")
		## End of modifying 'die' command

		x="$(cat ${EROOT}/etc/portage/make.conf | grep --color=never EHOOKS_ACCEPT)"
		[[ -n ${x} ]] && eval "$x" ## Needed when installing binary package
		if [[ ${EHOOKS_ACCEPT} != "yes" ]]; then
			eerror
			eerror "Warning!"
			eerror
			eerror "Patches from gentoo-unity7 overlay will be applied to ${CATEGORY}/${PN} and some other packages from the Gentoo tree via ehooks patching system."
			eerror "For more details, see ${REPO_ROOT}/docs/ehooks.md - Chapter I."
			eerror "Set EHOOKS_ACCEPT=\"yes\" in make.conf to confirm you agree with it."
			eerror
			echo "Acceptance needed" > "${log}"
			die "$(<${log})"
		fi

		declare -F ehooks 1>/dev/null \
			&& ( echo "ehooks: function name collision" > "${log}" && die "$(<${log})" )

		echo "${color_red}${color_bold}>>> Loading gentoo-unity7 ehooks ...${color_norm}"
		for x in "${EHOOKS_SOURCE[@]}"; do

		## Process current phase.
		if [[ ${x} == *"${FUNCNAME[1]}.ehooks" ]]; then

		[[ -r ${x} ]] \
			|| ( echo "${x##*/}: file not readable" > "${log}" && die "$(<${log})" )

		source "${x}" 2>"${log}"
		[[ -s ${log} ]] \
			&& die "$(<${log})"

		declare -F ehooks 1>/dev/null \
			|| ( echo "ehooks: function not found" > "${log}" && die "$(<${log})" )

		einfo "Processing ${x} ..."

		local EHOOKS_FILESDIR=${x%/*}/files

		## Check for eautoreconf.
		if [[ ${EBUILD_PHASE} == prepare ]]; then

		if declare -f ehooks | grep -q "eautoreconf"; then
			if ! declare -F eautoreconf 1>/dev/null; then
				local eautoreconf_names="eautoreconf _at_uses_pkg _at_uses_autoheader _at_uses_automake _at_uses_gettext _at_uses_glibgettext _at_uses_intltool _at_uses_gtkdoc _at_uses_gnomedoc _at_uses_libtool _at_uses_libltdl eaclocal_amflags eaclocal _elibtoolize eautoheader eautoconf eautomake autotools_env_setup autotools_run_tool ALL_AUTOTOOLS_MACROS autotools_check_macro autotools_check_macro_val _autotools_m4dir_include autotools_m4dir_include autotools_m4sysdir_include gnuconfig_findnewest elibtoolize tc-getLD tc-getPROG _tc-getPROG"

				x=$("${PORTAGE_QUERY_TOOL}" get_repo_path / gentoo)/eclass
				local -a fn_source=(
					"${x}/autotools.eclass"
					"${x}/libtool.eclass"
					"${x}/gnuconfig.eclass"
					"${x}/toolchain-funcs.eclass"
				)

				for x in "${fn_source[@]}"; do
					[[ -f ${x} ]] \
						|| ( echo "${x}: file not found" > "${log}" && die "$(<${log})" )

					source <(awk "/^(${eautoreconf_names// /|})(\(\)|=\(\$)/ { p = 1 } p { print } /(^(}|\))|; })\$/ { p = 0 }" ${x} 2>/dev/null)
				done

				declare -F eautoreconf 1>/dev/null \
					|| ( echo "eautoreconf: function not found" > "${log}" && die "$(<${log})" )
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
		ehooks 2>&1 >&3 | tee -a "${log}"

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

		fi ## End of processing EHOOKS_SOURCE.
	} ## End of ehooks_apply function.

	pre_pkg_setup() { ehooks_apply; }
	post_pkg_setup() { ehooks_apply; }
	pre_src_unpack() { ehooks_apply; }
	post_src_unpack() { ehooks_apply; }
	pre_src_prepare() { ehooks_apply; }
	post_src_prepare() { ehooks_apply; }
	pre_src_configure() { ehooks_apply; }
	post_src_configure() { ehooks_apply; }
	pre_src_compile() { ehooks_apply; }
	post_src_compile() { ehooks_apply; }
	pre_src_install() { ehooks_apply; }
	post_src_install() { ehooks_apply; }
	pre_pkg_preinst() { ehooks_apply; }
	post_pkg_preinst() { ehooks_apply; }
	pre_pkg_postinst() { ehooks_apply; }
	post_pkg_postinst() { ehooks_apply; }
fi ## End of setup phase.

## Check for {pre,post} function name collision with ehooks patching system.
if [[ ${EBUILD_PHASE} == "unpack" ]]; then
	local x
	local -a EHOOKS_FUNC=()
	for x in {pre,post}_pkg_{setup,preinst,postinst} {pre,post}_src_{unpack,prepare,configure,compile,install}; do
		! declare -F ${x} 1>/dev/null || declare -f ${x} | grep -q "ehooks_apply" || EHOOKS_FUNC+=( "'${x}'," )
	done
	[[ -n ${EHOOKS_FUNC[@]} ]] && EHOOKS_FUNC[-1]="${EHOOKS_FUNC[-1]%,}" && die "ehooks: function name collision\n  If you have ${EHOOKS_FUNC[@]} inside '${EROOT}/etc/portage/bashrc', call 'ehooks_apply' function inside it or use generic ehooks instead.\n  For more details, see ${REPO_ROOT}/docs/ehooks.md - Chapter II. - Generic ehooks."
fi
## End of ehooks patching system.
