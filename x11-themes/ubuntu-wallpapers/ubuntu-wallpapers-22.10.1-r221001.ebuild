# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=0ubuntu1

inherit ubuntu-versionator

DESCRIPTION="Ubuntu wallpapers"
HOMEPAGE="https://launchpad.net/ubuntu-wallpapers"
SRC_URI="${UURL}-${UREV}_all.deb"

CODENAME="karmic lucid maverick natty oneiric precise quantal raring
saucy trusty utopic vivid wily xenial yakkety zesty artful bionic cosmic
disco eoan focal groovy hirsute impish jammy +kinetic"
for c in ${CODENAME}; do
	c="${c#+}"
	SRC_URI+=" ${c}? ( ${UURL/_/-${c}_}-${UREV}_all.deb )"
done

LICENSE="CC-BY-SA-3.0"
#KEYWORDS="~amd64"
SLOT="0"
IUSE="gnome ${CODENAME}"
RESTRICT="binchecks strip test"

PDEPEND="gnome? ( x11-themes/gnome-backgrounds )"

S="${WORKDIR}"

src_unpack() {
	if [[ -n ${A} ]]; then
		for a in ${A}; do
			unpack ${a}
			if [[ -f data.tar.xz ]]; then
				unpack "${PWD}"/data.tar.xz
				rm control.tar.xz data.tar.xz
			else
				tar -I zstd -xf "${PWD}"/data.tar.zst
				rm control.tar.zst data.tar.zst
			fi
			rm debian-binary
		done
	else
		die "Source files not found"
	fi
}

src_install() {
	pushd "${S}"/usr/share >/dev/null || die
		insinto /usr/share/backgrounds
		doins backgrounds/{*.jpg,*.png}

		insinto /usr/share/backgrounds/contest
		doins backgrounds/contest/*.xml

		insinto /usr/share/gnome-background-properties
		doins gnome-background-properties/*.xml

		dodoc doc/"${PN}"/copyright
	popd >/dev/null || die
}
