# Copyright 1999-2026 Gentoo Authors
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
IUSE="+appearance +battery bluetooth +cups +datetime java8 java11 java17 java21 java25 +keyboard mail +notifications paste sensors +session +sound weather"
RESTRICT="binchecks strip test"

RDEPEND="
	unity-indicators/indicator-appmenu
	unity-indicators/indicator-datetime

	appearance? ( unity-indicators/unity-indicator-appearance )
	battery? ( unity-indicators/indicator-power )
	bluetooth? ( unity-indicators/indicator-bluetooth )
	cups? ( unity-indicators/indicator-printers )
	java8? ( dev-java/jayatana:8 )
	java11? ( dev-java/jayatana:11 )
	java17? ( dev-java/jayatana:17 )
	java21? ( dev-java/jayatana:21 )
	java25? ( dev-java/jayatana:25 )
	keyboard? ( unity-indicators/indicator-keyboard )
	mail? ( net-mail/mailnag[messagingmenu] )
	notifications? ( unity-indicators/indicator-notifications )
	paste? ( unity-extra/diodon )
	sensors? ( unity-extra/indicator-psensor )
	session? ( unity-indicators/indicator-session )
	sound? ( unity-indicators/indicator-sound )
	weather? ( unity-extra/meteo-qt )
"

S="${WORKDIR}"
