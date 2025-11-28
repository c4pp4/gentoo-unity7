#!/bin/bash

# Allow the user to override command-line flags, bug #357629.
# This is based on Debian's chromium-browser package, and is intended
# to be consistent with Debian.
for f in /etc/chromium/*; do
    [[ -f ${f} ]] && source "${f}"
done

# Prefer user defined CHROMIUM_USER_FLAGS (from env) over system
# default CHROMIUM_FLAGS (from /etc/chromium/default).
CHROMIUM_FLAGS=${CHROMIUM_USER_FLAGS:-"$CHROMIUM_FLAGS"}

# Let the wrapped binary know that it has been run through the wrapper
export CHROME_WRAPPER=$(readlink -f "$0")

PROGDIR=${CHROME_WRAPPER%/*}

case ":$PATH:" in
  *:$PROGDIR:*)
    # $PATH already contains $PROGDIR
    ;;
  *)
    # Append $PROGDIR to $PATH
    export PATH="$PATH:$PROGDIR"
    ;;
esac

# Select session type and platform
if @@OZONE_AUTO_SESSION@@; then
	platform=
	if [[ ${XDG_SESSION_TYPE} == x11 ]]; then
		platform=x11
	elif [[ ${XDG_SESSION_TYPE} == wayland ]]; then
		platform=wayland
	else
		if [[ -n ${WAYLAND_DISPLAY} ]]; then
			platform=wayland
		else
			platform=x11
		fi
	fi
	if ${DISABLE_OZONE_PLATFORM:-false}; then
		platform=x11
	fi
	CHROMIUM_FLAGS="--ozone-platform=${platform} ${CHROMIUM_FLAGS}"
fi

# Set the .desktop file name
export CHROME_DESKTOP="chromium-browser-chromium.desktop"

if [[ $1 == "--temp-profile" ]]; then
    TEMP_PROFILE=$(mktemp -d)
    CHROMIUM_FLAGS="--user-data-dir=${TEMP_PROFILE} ${CHROMIUM_FLAGS}"

    CHROMIUM_FLAGS="--start-maximized ${CHROMIUM_FLAGS}"

    # Disable running background apps when Chromium is closed
    echo '{"background_mode":{"enabled":false}}' > "${TEMP_PROFILE}/Local State"

    # We can't exec here as we need to clean-up the temporary profile
    "$PROGDIR/chrome" --extra-plugin-dir=/usr/lib/nsbrowser/plugins ${CHROMIUM_FLAGS} "$@"
    rm -rf ${TEMP_PROFILE}
else
    if [[ ${EUID} == 0 && -O ${XDG_CONFIG_HOME:-${HOME}} ]]; then
	    # Running as root with HOME owned by root.
	    # Pass --user-data-dir to work around upstream failsafe.
	    CHROMIUM_FLAGS="--user-data-dir=${XDG_CONFIG_HOME:-${HOME}/.config}/chromium
		    ${CHROMIUM_FLAGS}"
    fi

    exec -a "chromium-browser" "$PROGDIR/chrome" --extra-plugin-dir=/usr/lib/nsbrowser/plugins ${CHROMIUM_FLAGS} "$@"
fi
