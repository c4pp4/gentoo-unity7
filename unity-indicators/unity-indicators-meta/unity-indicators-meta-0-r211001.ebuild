# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=

inherit ubuntu-versionator

DESCRIPTION="Unity Desktop - merge this to pull in all Unity indicators"
HOMEPAGE="https://wiki.ubuntu.com/Unity"
SRC_URI=""

LICENSE="metapackage"
SLOT="0"
KEYWORDS="amd64"
IUSE="+battery bluetooth +cups +datetime java +keyboard mail paste sensors +session +sound weather"
RESTRICT="binchecks strip test"

RDEPEND="
	unity-indicators/indicator-appmenu
	unity-indicators/indicator-datetime

	battery? ( unity-indicators/indicator-power )
	bluetooth? ( unity-indicators/indicator-bluetooth )
	cups? ( unity-indicators/indicator-printers )
	java? ( dev-java/jayatana )
	keyboard? ( unity-indicators/indicator-keyboard )
	mail? ( net-mail/mailnag[messagingmenu] )
	paste? ( unity-extra/diodon )
	sensors? ( unity-extra/indicator-psensor )
	session? ( unity-indicators/indicator-session )
	sound? ( unity-indicators/indicator-sound )
	weather? ( unity-extra/meteo-qt )
"

S="${WORKDIR}"
