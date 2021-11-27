# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{8..10} )

UVER="+15.10.20150806"
UREV="0ubuntu24"

inherit cmake-utils python-r1 ubuntu-versionator

DESCRIPTION="Error tolerant matching engine used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/libcolumbus"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-2"
SLOT="0/${PV}"
KEYWORDS="~amd64"
IUSE="debug test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}
	test? ( debug )"

DEPEND="dev-cpp/sparsehash
	dev-libs/boost:=[python,${PYTHON_USEDEP}]
	>=dev-libs/icu-52:=
	${PYTHON_DEPS}"

S="${S}${UVER}"

src_prepare() {
	ubuntu-versionator_src_prepare

	python_copy_sources
	preparation() {
		python_fix_shebang .
		cp -rfv python/pch/colpython_pch.hh "${BUILD_DIR}/python/colpython_pch.hh"
		cmake-utils_src_prepare
	}
	python_foreach_impl run_in_build_dir preparation
}

src_configure() {
	configuration() {
		mycmakeargs+=(-DPYTHONDIR="$(python_get_sitedir)")
		cmake-utils_src_configure
	}
	python_foreach_impl run_in_build_dir configuration
}

src_compile() {
	compilation() {
		cmake-utils_src_compile
	}
	python_foreach_impl run_in_build_dir compilation
}

src_test() {
	testing() {
		cmake-utils_src_test
	}
	python_foreach_impl run_in_build_dir testing
}

src_install() {
	local DOCS=( 'coding style.txt' hacking.txt readme.txt )
	installation() {
		cmake-utils_src_install
	}
	python_foreach_impl run_in_build_dir installation
}
