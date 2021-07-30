# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

URELEASE="hirsute"
inherit ubuntu-versionator

DESCRIPTION="Ubuntu wallpapers"
HOMEPAGE="https://launchpad.net/ubuntu-wallpapers"

SRC_URI="${UURL}/${MY_P}${UVER_PREFIX}-${UVER}_all.deb
	${UURL}/${PN}-${URELEASE%-*}_${PV}${UVER_PREFIX}-${UVER}_all.deb"

CODENAME="karmic lucid maverick natty oneiric precise quantal raring
saucy trusty utopic vivid wily xenial yakkety zesty artful bionic cosmic
disco eoan focal groovy"

for c in ${CODENAME}; do
	SRC_URI+=" ${c}? ( ${UURL}/${PN}-${c}_${PV}${UVER_PREFIX}-${UVER}_all.deb )"
done

LICENSE="CC-BY-SA-3.0"
KEYWORDS="~amd64"
SLOT="0"
IUSE="gnome ${CODENAME} +${URELEASE%-*}"
RESTRICT="mirror"

RDEPEND="gnome? ( x11-themes/gnome-backgrounds )"

S="${WORKDIR}"

src_unpack() {
	if [[ -n ${A} ]]; then
		for a in ${A}; do
			unpack ${a}
			unpack ${PWD}/data.tar.xz
			rm control.tar.xz data.tar.xz debian-binary
		done
	else
		die "Source files not found"
	fi
}

src_compile() { :; }
src_test() { :; }

src_install() {
	pushd "${S}"/usr/share 1>/dev/null
		insinto /usr/share/backgrounds
		doins backgrounds/{*.jpg,*.png}

		insinto /usr/share/backgrounds/contest
		doins backgrounds/contest/*.xml

		insinto /usr/share/gnome-background-properties
		doins gnome-background-properties/*.xml

		dodoc doc/"${PN}"/copyright
	popd 1>/dev/null
}
