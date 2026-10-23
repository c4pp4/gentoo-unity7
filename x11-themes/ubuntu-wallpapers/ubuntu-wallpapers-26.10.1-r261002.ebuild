# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

UVER=
UREV=

inherit ubuntu-versionator

DESCRIPTION="Ubuntu wallpapers"
HOMEPAGE="https://launchpad.net/ubuntu-wallpapers"
SRC_URI="${UURL}${UREV:+-${UREV}}_all.deb"
S="${WORKDIR}"

CODENAME="karmic lucid maverick natty oneiric precise quantal raring
saucy trusty utopic vivid wily xenial yakkety zesty artful bionic cosmic
disco eoan focal groovy hirsute impish jammy kinetic lunar mantic noble
oracular plucky questing resolute +stonking"
for c in ${CODENAME}; do
	c="${c#+}"
	SRC_URI+=" ${c}? ( ${UURL/_/-${c}_}${UREV:+-${UREV}}_all.deb )"
done

LICENSE="CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="amd64"
IUSE="gnome ${CODENAME}"
RESTRICT="binchecks strip test"

PDEPEND="gnome? ( x11-themes/gnome-backgrounds )"
BDEPEND="app-arch/zstd"

src_unpack() {
	local a

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
		# Fix resolute contest xml path #
		if [[ -e gnome-background-properties/resolute-wallpapers.xml ]]; then
			sed -i \
				-e "s:backgrounds/resolute.xml:backgrounds/contest/resolute.xml:" \
				gnome-background-properties/resolute-wallpapers.xml || die
			grep -Fq "backgrounds/contest/resolute.xml" gnome-background-properties/resolute-wallpapers.xml || die
		fi

		insinto /usr/share
		doins -r backgrounds gnome-background-properties

		## Install the Ubuntu copyright file of the main package.
		[[ -s doc/${PN}/copyright ]] && dodoc "doc/${PN}/copyright"

		## Install the Ubuntu changelog and copyright files of enabled releases.
		local c
		for c in ${CODENAME}; do
			c="${c#+}"
			use "${c}" || continue
			## Decompress the changelog, Portage compresses documentation itself.
			if [[ -s doc/${PN}-${c}/changelog.gz ]]; then
				gzip -dc "doc/${PN}-${c}/changelog.gz" > "${T}/${c}.changelog" || die
				dodoc "${T}/${c}.changelog"
			fi
			[[ -s doc/${PN}-${c}/copyright ]] && newdoc "doc/${PN}-${c}/copyright" "${c}.copyright"
		done
	popd >/dev/null || die
}
