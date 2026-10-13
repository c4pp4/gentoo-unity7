# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{12..15} )

UVER=+15.10.20150806
UREV=0ubuntu39

inherit cmake python-single-r1 ubuntu-versionator

DESCRIPTION="Error tolerant matching engine used by the Unity7 user interface"
HOMEPAGE="https://launchpad.net/libcolumbus"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"
S="${S}${UVER}"

LICENSE="LGPL-3"
SLOT="0/$(usub)"
KEYWORDS="amd64"
IUSE="coverage debug pch test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RESTRICT="!test? ( test )"

COMMON_DEPEND="
	>=dev-libs/icu-67.1:=

	${PYTHON_DEPS}
	$(python_gen_cond_dep 'dev-libs/boost:=[python,${PYTHON_USEDEP}]')
"
RDEPEND="${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND}
	dev-cpp/sparsehash
"
BDEPEND="
	${PYTHON_DEPS}
	virtual/pkgconfig

	coverage? (
		dev-util/gcovr
		dev-util/lcov
	)
"

DOCS=( "coding style.txt" hacking.txt readme.txt )

src_prepare() {
	python_fix_shebang .

	# Disable already applied patch #
	sed -i \
		-e '/^+++ .*debian\/patches\/series/,/^--- / s/^+0001-fix-build-with-python3\.10\.patch$/+#0001-fix-build-with-python3.10.patch/' \
		"${WORKDIR}/${PN}_${PV}${UVER}-${UREV}.diff" || die

	# Fix build with CMake 4 #
	sed -i "/cmake_minimum_required/{s/2\.8\.9/3.10/}" CMakeLists.txt || die

	# Don't build uninstalled tools (automagic GTK+ 3 GUI apps) #
	sed -i "/add_subdirectory(tools)/d" CMakeLists.txt || die

	ubuntu-versionator_src_prepare
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

src_test() {
	# Use data files from the source tree, not the installed ones #
	COLUMBUS_DATADIR="${S}"/share cmake_src_test
}
