# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Unity Desktop - merge this to pull in all Unity indicators"
HOMEPAGE="http://unity.ubuntu.com/"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+battery bluetooth +cups +datetime +keyboard mail paste sensors +session +sound weather"
RESTRICT="mirror"

RDEPEND="unity-indicators/indicator-application
	unity-indicators/indicator-appmenu
	battery? ( unity-indicators/indicator-power )
	bluetooth? ( unity-indicators/indicator-bluetooth )
	cups? ( unity-indicators/indicator-printers )
	datetime? ( unity-indicators/indicator-datetime )
	keyboard? ( unity-indicators/indicator-keyboard )
	mail? ( net-mail/mailnag x11-plugins/mailnag-messagingmenu-plugin )
	paste? ( unity-extra/diodon )
	sensors? ( unity-extra/indicator-psensor )
	session? ( unity-indicators/indicator-session )
	sound? ( unity-indicators/indicator-sound )
	weather? ( unity-extra/meteo-qt )"
