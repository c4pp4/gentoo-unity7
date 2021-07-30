# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Unity Desktop - merge this to pull in all Unity lenses"
HOMEPAGE="http://unity.ubuntu.com/"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+files +music +photos plugins +video"
RESTRICT="mirror"

RDEPEND="unity-lenses/unity-lens-applications
	unity-scopes/unity-scope-home

	files? ( unity-lenses/unity-lens-files )
	music? ( unity-lenses/unity-lens-music )
	photos? ( unity-lenses/unity-lens-photos )
	plugins? ( unity-scopes/smart-scopes )
	video? ( unity-lenses/unity-lens-video )"

PDEPEND="unity-base/unity-settings[files=,music=,photos=,video=]"
