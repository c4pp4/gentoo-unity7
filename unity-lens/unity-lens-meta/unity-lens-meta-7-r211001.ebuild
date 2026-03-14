# Copyright 1999-2026 Gentoo Authors
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
	unity-lens/unity-lens-applications
	unity-lens/unity-scope-home

	files? ( unity-lens/unity-lens-files )
	music? ( unity-lens/unity-lens-music )
	photos? ( unity-lens/unity-lens-photos )
	plugins? ( unity-lens/unity-scope-extras )
	video? ( unity-lens/unity-lens-video )
"

PDEPEND="unity-base/unity-settings[files=,music=,photos=,video=]"

S="${WORKDIR}"
