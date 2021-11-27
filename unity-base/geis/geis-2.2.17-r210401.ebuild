# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{8..10} )

UVER="+16.04.20160126"
UREV="0ubuntu7"

inherit autotools python-r1 ubuntu-versionator

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

src_prepare() {
	ubuntu-versionator_src_prepare
	eautoreconf
}

src_configure() {
	python_copy_sources
	configuration() {
		default
	}
	python_foreach_impl run_in_build_dir configuration
}

src_compile() {
	compilation() {
		default
		use doc && emake doc-html
	}
	python_foreach_impl run_in_build_dir compilation
}

src_install() {
	installation() {
		default
	}
	python_foreach_impl run_in_build_dir installation

	find "${ED}" \( -name "*.a" -o -name "*.la" \) -delete || die
}
