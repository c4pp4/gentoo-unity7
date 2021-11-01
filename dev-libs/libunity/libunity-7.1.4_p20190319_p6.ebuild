# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{8..10} )

MY_PV="${PV}"
URELEASE="jammy"
inherit autotools eutils python-r1 ubuntu-versionator vala

UVER_PREFIX="+19.04.${PVR_MICRO}"
UVER="-${PVR_PL_MAJOR}"

DESCRIPTION="Library for instrumenting and integrating with all aspects of the Unity shell"
HOMEPAGE="https://launchpad.net/libunity"
SRC_URI="${UURL}/${MY_P}${UVER_PREFIX}.orig.tar.gz
	${UURL}/${MY_P}${UVER_PREFIX}${UVER}.diff.gz"

LICENSE="GPL-3"
SLOT="0/9.0.2"
#KEYWORDS="~amd64"
IUSE=""
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RESTRICT="mirror"

DEPEND=">=dev-libs/dee-1.2.5:=
	dev-libs/libdbusmenu:=
	x11-libs/gtk+:3
	${PYTHON_DEPS}
	$(vala_depend)"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	mkdir "${MY_P}"
	pushd "${MY_P}" 1>/dev/null
		unpack ${A}
		mv "${MY_P}${UVER_PREFIX}${UVER}.diff" "${WORKDIR}"
	popd 1>/dev/null
}

src_prepare() {
	ubuntu-versionator_src_prepare
	vala_src_prepare
	export VALA_API_GEN="$VAPIGEN"
	eautoreconf
}

src_configure() {
	python_copy_sources
	configuration() {
		econf || die
	}
	python_foreach_impl run_in_build_dir configuration
}

src_compile() {
	compilation() {
		emake || die
	}
	python_foreach_impl run_in_build_dir compilation
}

src_install() {
	installation() {
		emake DESTDIR="${D}" install
	}
	python_foreach_impl run_in_build_dir installation
	prune_libtool_files --modules
}
