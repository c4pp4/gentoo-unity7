# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=

inherit ubuntu-versionator

DESCRIPTION="Unity Desktop - merge this to pull in all Unity lenses"
HOMEPAGE="https://wiki.ubuntu.com/Unity"
SRC_URI=""

LICENSE="metapackage"
SLOT="0"
KEYWORDS="amd64"
IUSE="+files +music +photos plugins +video"
RESTRICT="binchecks strip test"

RDEPEND="
	unity-lenses/unity-lens-applications
	unity-scopes/unity-scope-home

	files? ( unity-lenses/unity-lens-files )
	music? ( unity-lenses/unity-lens-music )
	photos? ( unity-lenses/unity-lens-photos )
	plugins? ( unity-scopes/smart-scopes )
	video? ( unity-lenses/unity-lens-video )
"

PDEPEND="unity-base/unity-settings[files=,music=,photos=,video=]"

S="${WORKDIR}"
