# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{8..10} )
UBUNTU_EAUTORECONF="yes"

UVER="+16.04.20160126"
UREV="0ubuntu7"

inherit python-r1 ubuntu-versionator

DESCRIPTION="An implementation of the GEIS (Gesture Engine Interface and Support) interface"
HOMEPAGE="https://launchpad.net/geis"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.diff.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="unity-base/grail
	${PYTHON_DEPS}"

S="${S}${UVER}"

src_configure() {
	python_copy_sources
	python_foreach_impl run_in_build_dir default
}

src_compile() {
	compilation() {
		default
		use doc && emake doc-html
	}
	python_foreach_impl run_in_build_dir compilation
}

src_install() {
	python_foreach_impl run_in_build_dir default

	find "${ED}" \( -name "*.a" -o -name "*.la" \) -delete || die
}
