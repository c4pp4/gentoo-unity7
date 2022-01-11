# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{8..10} )
UBUNTU_EAUTORECONF="yes"

UVER="+19.04.20190319"
UREV="6"

inherit python-r1 vala ubuntu-versionator

DESCRIPTION="Library for instrumenting and integrating with all aspects of the Unity shell"
HOMEPAGE="https://launchpad.net/libunity"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-3"
SLOT="0/9.0.2"
#KEYWORDS="~amd64"
IUSE=""
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND=">=dev-libs/dee-1.2.5:=
	dev-libs/libdbusmenu:=
	x11-libs/gtk+:3
	${PYTHON_DEPS}
	$(vala_depend)"

src_unpack() {
	mkdir "${P}"
	pushd "${P}" 1>/dev/null
		unpack ${A}
		mv "${PN}_${PV}${UVER}-${UREV}.diff" "${WORKDIR}"
	popd 1>/dev/null
}

src_configure() {
	python_copy_sources
	python_foreach_impl run_in_build_dir default
}

src_compile() { python_foreach_impl run_in_build_dir default; }

src_install() {
	python_foreach_impl run_in_build_dir default

	find "${ED}" \( -name "*.a" -o -name "*.la" \) -delete || die
}
