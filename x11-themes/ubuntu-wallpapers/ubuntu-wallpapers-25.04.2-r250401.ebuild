# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=

inherit ubuntu-versionator

DESCRIPTION="Ubuntu wallpapers"
HOMEPAGE="https://launchpad.net/ubuntu-wallpapers"
SRC_URI="${UURL}${UREV:+-${UREV}}_all.deb"

CODENAME="karmic lucid maverick natty oneiric precise quantal raring
saucy trusty utopic vivid wily xenial yakkety zesty artful bionic cosmic
disco eoan focal groovy hirsute impish jammy kinetic lunar mantic noble
oracular +plucky"
for c in ${CODENAME}; do
	c="${c#+}"
	SRC_URI+=" ${c}? ( ${UURL/_/-${c}_}${UREV:+-${UREV}}_all.deb )"
done

LICENSE="CC-BY-SA-3.0"
KEYWORDS="amd64"
SLOT="0"
IUSE="gnome ${CODENAME}"
RESTRICT="binchecks strip test"

PDEPEND="gnome? ( x11-themes/gnome-backgrounds )"

S="${WORKDIR}"

src_unpack() {
	if [[ -n ${A} ]]; then
		for a in ${A}; do
			unpack ${a}
			tar -I zstd -xf "${PWD}"/data.tar.zst || die
			rm control.tar.zst data.tar.zst debian-binary || die
		done
	else
		die "Source files not found"
	fi
}

src_install() {
	pushd "${S}"/usr/share >/dev/null || die
		insinto /usr/share
		doins -r backgrounds

		insinto /usr/share
		doins -r gnome-background-properties

		dodoc doc/"${PN}"/copyright
	popd >/dev/null || die
}
