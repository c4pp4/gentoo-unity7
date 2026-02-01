# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{10..14} )

UVER=+15.10.20150806
UREV=0ubuntu38

inherit cmake python-single-r1 ubuntu-versionator

DESCRIPTION="Error tolerant matching engine used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/libcolumbus"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="LGPL-3"
SLOT="0/$(usub)"
KEYWORDS="~amd64"
IUSE="coverage debug pch test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RESTRICT="!test? ( test )"

COMMON_DEPEND="
	>=dev-libs/icu-67.1:=

	${PYTHON_DEPS}
	$(python_gen_cond_dep 'dev-libs/boost:=[python,${PYTHON_USEDEP}]')
"
RDEPEND="${COMMON_DEPEND}
	>=sys-devel/gcc-5.2
	>=sys-libs/glibc-2.14
"
DEPEND="${COMMON_DEPEND}
	dev-cpp/sparsehash

	coverage? (
		dev-util/gcovr
		dev-util/lcov
	)
"
BDEPEND="virtual/pkgconfig"

S="${S}${UVER}"

src_prepare() {
	python_fix_shebang .

	local diff_file="${WORKDIR}/${PN}_${PV}${UVER}-${UREV}.diff"
	mv "${diff_file}" "${diff_file}.ignore"

	# Fix build with CMake 4 #
	sed -i "/cmake_minimum_required/{s/2\.8\.9/3.10/}" CMakeLists.txt || die

	ubuntu-versionator_src_prepare

	echo "$(tput bold)>>> Processing Ubuntu diff file$(tput sgr0) ..."
	eapply "${diff_file}.ignore"
	echo "$(tput bold)>>> Done.$(tput sgr0)"
}

src_configure() {
	local mycmakeargs=(
		-Ddebug_messages=$(usex debug ON OFF)
		-Denable_tests=$(usex test ON OFF)
		-DPYTHONDIR=$(python_get_sitedir)
		-Duse_pch=$(usex pch)
		-Wno-dev
	)
	CMAKE_BUILD_TYPE=$(usex coverage coverage Gentoo) cmake_src_configure

	if use pch; then
		cp python/pch/colpython_pch.hh "${BUILD_DIR}"/python/colpython_pch.hh || die
	fi
}

src_install() {
	local DOCS=(
		"coding style.txt"
		hacking.txt
		readme.txt
	)
	cmake_src_install
}
