## ehooks patching system.
if [[ ${EBUILD_PHASE} == "setup" ]]; then
	## Get the gentoo-unity7 repository path using portageq.
	PORTAGE_QUERY_TOOL=portageq
	[[ -e "${PORTAGE_BIN_PATH}"/portageq-wrapper ]] && PORTAGE_QUERY_TOOL="${PORTAGE_BIN_PATH}"/portageq-wrapper
	if ! REPO_ROOT=$("${PORTAGE_QUERY_TOOL}" get_repo_path / gentoo-unity7 2>/dev/null) || [[ -z ${REPO_ROOT} ]]; then
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

	## Define a function to apply ehooks.
	ehooks_apply() {
		## Redirect shell tracing to FD 3.
		local BASH_XTRACEFD=3

		## Process EHOOKS_SOURCE.
		if [[ ${EHOOKS_SOURCE[@]} == *"${FUNCNAME[1]}.ehooks"* ]]; then

		local \
			log="${T}/ehooks.log" \
			color_norm="${PORTAGE_COLOR_NORMAL}" \
			color_bold="${PORTAGE_COLOR_NORMAL:+$'\e[1m'}" \
			color_red="${PORTAGE_COLOR_BAD}" \
			x ehk

		> "${log}"

		## Add ehooks bug reporting information to the 'die' function.
		local \
			bugapnd="eerror \"S: '\${S}'\"" \
			bugmsg="eerror \"${color_bold}Please report ehooks bugs at ${color_norm}'https://github.com/c4pp4/gentoo-unity7/issues'.\"" \
			buglog="eerror \"${color_bold}The ehooks log is located at ${color_norm}'${log}'.\""

		source <(declare -f die | sed -e "/${bugapnd}/a ${bugmsg}" -e "/${bugapnd}/a ${buglog}")
		## End of modifications to the 'die' function.

		x="$(grep -rhE --color=never -- '^[[:space:]]*(export[[:space:]]+)?EHOOKS_ACCEPT=' "${PORTAGE_CONFIGROOT%/}"/etc/portage/make.conf 2>/dev/null)"
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

		echo "${color_red}>>> Loading gentoo-unity7 ehooks ...${color_norm}"
		for ehk in "${EHOOKS_SOURCE[@]}"; do

		## Process ehooks for the current phase.
		if [[ ${ehk} == *"${FUNCNAME[1]}.ehooks" ]]; then

		if [[ ! -r ${ehk} ]]; then
			echo "${ehk##*/}: file not readable" > "${log}"
			die "$(<${log})"
		fi

		source "${ehk}" 2>"${log}"
		[[ -s ${log} ]] \
			&& die "$(<${log})"

		if ! declare -F ehooks 1>/dev/null; then
			echo "ehooks: function not found" > "${log}"
			die "$(<${log})"
		fi

		einfo "Processing ${ehk} ..."

		local EHOOKS_FILESDIR=${ehk%/*}/files

		## Load eautoreconf and its helpers if needed.
		local eautoreconf_loaded=""
		if [[ ${EBUILD_PHASE} == prepare ]]; then

		if declare -f ehooks | grep -q "eautoreconf"; then
			if ! declare -F eautoreconf 1>/dev/null; then
				local eautoreconf_names="eautoreconf _at_uses_pkg _at_uses_autoheader _at_uses_automake _at_uses_gettext _at_uses_glibgettext _at_uses_intltool _at_uses_gtkdoc _at_uses_gnomedoc _at_uses_libtool _at_uses_libltdl eaclocal_amflags eaclocal _elibtoolize eautoheader eautoconf eautomake autotools_env_setup autotools_run_tool ALL_AUTOTOOLS_MACROS autotools_check_macro autotools_check_macro_val _autotools_m4dir_include autotools_m4dir_include autotools_m4sysdir_include gnuconfig_findnewest elibtoolize tc-getLD tc-getPROG _tc-getPROG"

				## Load only definitions missing from the ebuild environment
				## (e.g. elibtoolize or tc-getLD from inherited eclasses).
				for x in ${eautoreconf_names}; do
					declare -F ${x} 1>/dev/null || [[ -v ${x} ]] || eautoreconf_loaded+=" ${x}"
				done
				eautoreconf_loaded="${eautoreconf_loaded# }"

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

					## WANT_AUTO{CONF,MAKE} are left unset, so autotools wrappers select the version.
					source <(awk "/^(${eautoreconf_loaded// /|})(\(\)|=\(\$)/ { p = 1 } p { print } /(^(}|\))|; })\$/ { p = 0 }" "${x}" 2>/dev/null)
				done

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

		## Display and log ehooks stderr; send ehooks stdout to FD 3.
		ehooks 2>&1 >&3 | tee -a "${log}"

		[[ -s ${log} ]] \
			&& die "$(<${log})"

		## Restore message functions and clean up temporary definitions.
		for x in ${msgfunc_names}; do
			source <(declare -f ${x} | sed "s/\(1>&\)3/\12/")
		done
		unset -f ehooks
		## Remove only definitions loaded for eautoreconf.
		for x in ${eautoreconf_loaded}; do
			unset ${x}
		done

		fi ## End of processing the current phase.

		done
		echo "${color_red}>>> Done.${color_norm}"

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
## and ehooks phase functions (binary packages have no unpack phase).
if [[ ${EBUILD_PHASE} == "unpack" ]] || \
	[[ ${EBUILD_PHASE} == "preinst" && ${EMERGE_FROM} == "binary" ]]; then
	local x
	local -a EHOOKS_FUNC=()
	for x in {pre,post}_pkg_{setup,preinst,postinst} {pre,post}_src_{unpack,prepare,configure,compile,install}; do
		! declare -F ${x} 1>/dev/null || declare -f ${x} | grep -q "ehooks_apply" || EHOOKS_FUNC+=( "'${x}'," )
	done
	[[ -n ${EHOOKS_FUNC[@]} ]] && EHOOKS_FUNC[-1]="${EHOOKS_FUNC[-1]%,}" && die "ehooks: function name collision\n  If you define ${EHOOKS_FUNC[@]} in '${PORTAGE_CONFIGROOT%/}/etc/portage/bashrc', call ehooks_apply inside each function, or use generic ehooks instead.\n  For more details, see Chapter II (Generic ehooks) of '${REPO_ROOT}/docs/ehooks.md'."
fi
## End of the ehooks patching system.
