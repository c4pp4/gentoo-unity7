## ehooks patching system.
if [[ ${EBUILD_PHASE} == "setup" ]]; then
	## Get the gentoo-unity7 repository path using portageq.
	PORTAGE_QUERY_TOOL=portageq
	[[ -e "${PORTAGE_BIN_PATH}"/portageq-wrapper ]] && PORTAGE_QUERY_TOOL="${PORTAGE_BIN_PATH}"/portageq-wrapper
	if "${PORTAGE_QUERY_TOOL}" get_repo_path / gentoo-unity7 >/dev/null 2>&1; then
		REPO_ROOT=$("${PORTAGE_QUERY_TOOL}" get_repo_path / gentoo-unity7)
	else
		die "portageq: path to the gentoo-unity7 repository not found. If you have recently updated sys-apps/portage, rerun 'emerge -avuDU --with-bdeps=y @world' to pick up any required updates."
	fi

	## Look for ehooks during the setup phase.
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

		## Skip ehooks in ${basedir}/generic for packages
		## from the gentoo-unity7 overlay.
		[[ ${PORTAGE_REPO_NAME} == "gentoo-unity7" ]] && \
		[[ ${EHOOKS_ROOT}/${pkg} == ${basedir}/"generic" ]] && \
		continue

		local prev_shopt=$(shopt -p nullglob)
		shopt -s nullglob
		EHOOKS_SOURCE+=( "${EHOOKS_ROOT}/${pkg}"/*.ehooks )
		${prev_shopt}
		[[ ${pkg} != "generic" ]] && break
	done

	## Define a function to check whether a USE flag is enabled
	## for unity-base/gentoo-unity-env.
	ehooks_use() {
		return $("${PORTAGE_QUERY_TOOL}" has_version / unity-base/gentoo-unity-env["$1"])
	}

	## Define a function to request skipping non-generic ehooks
	## if a required USE flag is not enabled for unity-base/gentoo-unity-env.
	ehooks_require() {
		if ! "${PORTAGE_QUERY_TOOL}" has_version / unity-base/gentoo-unity-env["$1"]; then
			echo " * Required USE flag '$1' is not enabled: skipping remaining non-generic ehooks..."
			exit ${SKIP_CODE}
		fi
	}

	## Define a function to apply ehooks.
	ehooks_apply() {
		## Redirect shell tracing to FD 3.
		local BASH_XTRACEFD=3

		## Process EHOOKS_SOURCE.
		if [[ ${EHOOKS_SOURCE[@]} == *"${FUNCNAME[1]}"* ]]; then

		local \
			x \
			log="${T}/ehooks.log" \
			color_norm=$(tput sgr0) \
			color_bold=$(tput bold) \
			color_red=$(tput setaf 1)

		> "${log}"

		## Add ehooks bug reporting information to the 'die' function.
		local \
			bugapnd="eerror \"S: '\${S}'\"" \
			bugmsg="eerror \"${color_bold}Please report ehooks bugs at ${color_norm}'https://github.com/c4pp4/gentoo-unity7/issues'.\"" \
			buglog="eerror \"${color_bold}The ehooks log is located at ${color_norm}'${log}'.\""

		source <(declare -f die | sed -e "/${bugapnd}/a ${bugmsg}" -e "/${bugapnd}/a ${buglog}")
		## End of modifications to the 'die' function.

		x="$(grep -rh --color=never -- '^EHOOKS_ACCEPT=' ${EROOT}/etc/portage/make.conf)"
		[[ -n ${x} ]] && eval "$x" ## Needed when installing a binary package.
		if [[ ${EHOOKS_ACCEPT} != "yes" ]]; then
			eerror
			eerror "Warning:"
			eerror
			eerror "The ehooks patching system from the gentoo-unity7 overlay will apply patches to ${CATEGORY}/${PN} and other packages from the Gentoo tree."
			eerror "For more details, see Chapter I of '${REPO_ROOT}/docs/ehooks.md'."
			eerror "Set EHOOKS_ACCEPT=\"yes\" in make.conf to accept the use of the ehooks patching system."
			eerror
			echo "Acceptance of ehooks patches is required." > "${log}"
			die "$(<${log})"
		fi

		if declare -F ehooks 1>/dev/null; then
			echo "ehooks: function name collision" > "${log}"
			die "$(<${log})"
		fi

		echo "${color_red}${color_bold}>>> Loading gentoo-unity7 ehooks ...${color_norm}"
		for x in "${EHOOKS_SOURCE[@]}"; do

		## Always process generic ehooks, even after a skip request.
		[[ ${EHOOKS_SOURCE[-1]} == SKIP_NON-GENERIC ]] && \
		[[ ${x%/*} != *"/generic" ]] && \
		continue

		## Process ehooks for the current phase.
		if [[ ${x} == *"${FUNCNAME[1]}.ehooks" ]]; then

		if [[ ! -r ${x} ]]; then
			echo "${x##*/}: file not readable" > "${log}"
			die "$(<${log})"
		fi

		source "${x}" 2>"${log}"
		[[ -s ${log} ]] \
			&& die "$(<${log})"

		if ! declare -F ehooks 1>/dev/null; then
			echo "ehooks: function not found" > "${log}"
			die "$(<${log})"
		fi

		einfo "Processing ${x} ..."

		local EHOOKS_FILESDIR=${x%/*}/files

		## Load eautoreconf and its helpers if needed.
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
					if [[ ! -f ${x} ]]; then
						echo "${x}: file not found" > "${log}"
						die "$(<${log})"
					fi

					source <(awk "/^(${eautoreconf_names// /|})(\(\)|=\(\$)/ { p = 1 } p { print } /(^(}|\))|; })\$/ { p = 0 }" "${x}" 2>/dev/null)
				done

				source <(grep -rh --color=never -- '^_LATEST_AUTOCONF=' "${fn_source[0]}")
				source <(grep -rh --color=never -- '^_LATEST_AUTOMAKE=' "${fn_source[0]}")
				eautoreconf_names+=" _LATEST_AUTOCONF _LATEST_AUTOMAKE"

				if ! declare -F eautoreconf 1>/dev/null; then
					echo "eautoreconf: function not found" > "${log}"
					die "$(<${log})"
				fi
			fi
		fi

		fi ## End of eautoreconf handling.

		## Redirect informational messages to FD 3 instead of stderr (issue #193).
		local msgfunc_names="einfo einfon ewarn ebegin __eend __vecho elog eqawarn"

		for x in ${msgfunc_names}; do
			source <(declare -f ${x} | sed "s/\(1>&\)2/\13/")
		done

		## Define the exit code for requesting that non-generic ehooks be skipped.
		local SKIP_CODE=99

		## Display and log ehooks stderr; send ehooks stdout to FD 3.
		ehooks 2>&1 >&3 | tee -a "${log}"

		## Mark non-generic ehooks for skipping when SKIP_CODE is returned.
		## Check PIPESTATUS immediately after the ehooks pipeline.
		[[ ${PIPESTATUS[0]} -eq ${SKIP_CODE} ]] && \
		[[ ${EHOOKS_SOURCE[-1]} != SKIP_NON-GENERIC ]] && \
		EHOOKS_SOURCE+=( "SKIP_NON-GENERIC" )

		[[ -s ${log} ]] \
			&& die "$(<${log})"

		## Restore message functions and clean up temporary definitions.
		for x in ${msgfunc_names}; do
			source <(declare -f ${x} | sed "s/\(1>&\)3/\12/")
		done
		unset -f ehooks
		if [[ -n ${eautoreconf_names} ]]; then
			eautoreconf_names="${eautoreconf_names/ gnuconfig_findnewest elibtoolize tc-getLD tc-getPROG _tc-getPROG}"
			for x in ${eautoreconf_names}; do
				unset ${x}
			done
		fi

		fi ## End of processing the current phase.

		done
		echo "${color_red}${color_bold}>>> Done.${color_norm}"

		## Remove ehooks diagnostics from the 'die' function.
		source <(declare -f die | sed "/ehooks/d")

		fi ## End of processing EHOOKS_SOURCE.

		## Close the temporary tracing descriptor before restoring the caller's FD 3.
		unset BASH_XTRACEFD
	} 3>&1 ## End of the ehooks_apply function.

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
fi ## End of the setup phase.

## Check for name collisions between {pre,post} phase functions
## and ehooks phase functions.
if [[ ${EBUILD_PHASE} == "unpack" ]]; then
	local x
	local -a EHOOKS_FUNC=()
	for x in {pre,post}_pkg_{setup,preinst,postinst} {pre,post}_src_{unpack,prepare,configure,compile,install}; do
		! declare -F ${x} 1>/dev/null || declare -f ${x} | grep -q "ehooks_apply" || EHOOKS_FUNC+=( "'${x}'," )
	done
	[[ -n ${EHOOKS_FUNC[@]} ]] && EHOOKS_FUNC[-1]="${EHOOKS_FUNC[-1]%,}" && die "ehooks: function name collision\n  If you define ${EHOOKS_FUNC[@]} in '${EROOT}/etc/portage/bashrc', call ehooks_apply inside each function, or use generic ehooks instead.\n  For more details, see Chapter II (Generic ehooks) of '${REPO_ROOT}/docs/ehooks.md'."
fi
## End of the ehooks patching system.
