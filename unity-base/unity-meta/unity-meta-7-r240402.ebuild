# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=

inherit ubuntu-versionator

DESCRIPTION="Unity Desktop - merge this to pull in all Unity packages"
HOMEPAGE="https://wiki.ubuntu.com/Unity"
SRC_URI=""

LICENSE="metapackage"
SLOT="0"
KEYWORDS="amd64"
IUSE="+accessibility +apps chat +core +extra +fonts +games gnome +xdm"
REQUIRED_USE="gnome? ( extra )"
RESTRICT="binchecks strip test"

RDEPEND="
	gnome-extra/nm-applet
	media-fonts/dejavu
	unity-base/overlay-scrollbar
	unity-base/unity
	x11-misc/gtk3-nocsd
	x11-misc/notify-osd

	accessibility? (
		app-accessibility/at-spi2-atk
		app-accessibility/at-spi2-core:2
		app-accessibility/onboard
		app-accessibility/orca
	)
	apps? (
		|| (
			app-office/libreoffice
			app-office/libreoffice-bin
		)
		|| (
			mail-client/thunderbird
			mail-client/thunderbird-bin
			( mail-client/evolution unity-indicators/indicator-datetime[eds] )
		)
		|| (
			www-client/firefox
			www-client/firefox-bin
			www-client/chromium
			www-client/google-chrome
			www-client/microsoft-edge
			www-client/opera
			www-client/vivaldi
			www-client/epiphany
		)
	)
	chat? (
		|| (
			net-im/telegram-desktop
			net-im/telegram-desktop-bin
			( net-im/pidgin x11-plugins/pidgin-libnotify )
		)
	)
	core? (
		|| (
			( app-arch/engrampa gnome-extra/nemo-engrampa )
			( app-arch/file-roller gnome-extra/nemo-fileroller )
		)
		|| (
			app-editors/pluma
			app-editors/gedit
		)
		|| (
			app-text/atril
			app-text/evince
		)
		|| (
			mate-extra/mate-calc
			gnome-extra/gnome-calculator
		)
		mate-extra/mate-utils
		|| (
			media-gfx/eom
			media-gfx/eog:1
		)
		|| (
			media-gfx/shotwell
			media-gfx/gthumb
		)
		|| (
			media-sound/rhythmbox
			media-sound/audacious
		)
		|| (
			media-video/vlc
			media-video/totem
		)
		x11-terms/mate-terminal
	)
	extra? (
		app-crypt/seahorse
		gnome-base/dconf-editor
		|| (
			mate-extra/mate-system-monitor
			gnome-extra/gnome-system-monitor
		)
		media-gfx/simple-scan
		media-video/cheese
		net-misc/remmina
		net-misc/vino
		|| (
			net-p2p/transmission[appindicator,qt5]
			net-p2p/transmission[appindicator,qt6]
		)
		sys-apps/gnome-disk-utility
		unity-base/unity-control-center[gnome-online-accounts]
		unity-extra/unity-tweak-tool
		unity-indicators/indicator-keyboard[charmap]
		unity-indicators/indicator-power[powerman]
		unity-indicators/indicator-session[help]

		gnome? (
			app-backup/deja-dup
			gnome-extra/gnome-calendar
			gnome-extra/gnome-characters
			gnome-extra/gnome-contacts
			gnome-extra/gnome-weather
			media-gfx/gnome-font-viewer
		)
	)
	fonts? (
		|| (
			media-fonts/fonts-noto-cjk
			media-fonts/noto-cjk
		)
		media-fonts/freefont
		media-fonts/liberation-fonts
		media-fonts/noto
		media-fonts/noto-emoji
		media-fonts/urw-fonts
	)
	games? (
		games-arcade/gnome-nibbles
		games-arcade/gnome-robots
		games-board/four-in-a-row
		|| (
			games-board/gnome-chess
			games-board/pychess
		)
		games-board/gnome-mahjongg
		games-board/gnome-mines
		games-board/gnuchess
		games-board/iagno
		games-board/tali
		games-puzzle/five-or-more
		games-puzzle/gnome-klotski
		games-puzzle/gnome-sudoku
		games-puzzle/gnome-taquin
		games-puzzle/gnome-tetravex
		games-puzzle/hitori
		games-puzzle/lightsoff
		games-puzzle/quadrapassel
		games-puzzle/swell-foop
	)
	xdm? (
		|| (
			unity-extra/unity-greeter
			gnome-base/gdm
		)
	)
"

S="${WORKDIR}"
