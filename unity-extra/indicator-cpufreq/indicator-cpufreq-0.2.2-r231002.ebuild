# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..14} )

UVER=
UREV=0ubuntu4

inherit gnome2 distutils-r1 ubuntu-versionator

DESCRIPTION="CPU frequency scaling indicator for the Unity7 user interface"
HOMEPAGE="https://launchpad.net/indicator-cpufreq"
SRC_URI="${SRC_URI} ${UURL}-${UREV}.debian.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="test"

RDEPEND="
	>=dev-libs/libappindicator-0.1:3
	sys-power/cpufrequtils

	$(python_gen_cond_dep '
		dev-python/dbus-python[${PYTHON_USEDEP}]
		dev-python/pygobject:3[${PYTHON_USEDEP}]
	')
"
DEPEND="
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/python-distutils-extra[${PYTHON_USEDEP}]
	')
"

src_prepare() {
	# Allow users to use the indicator #
	sed -i \
		-e 's:auth_admin_keep:yes:' \
		indicator_cpufreq/com.ubuntu.indicatorcpufreq.policy.in || die

	ubuntu-versionator_src_prepare
}

src_install() {
	distutils-r1_src_install

	insinto /var/lib/polkit-1/localauthority/50-local.d
	doins "${WORKDIR}"/debian/"${PN}".pkla

	doman "${WORKDIR}"/debian/"${PN}".1
	doman "${WORKDIR}"/debian/"${PN}"-selector.1

	# Fix /etc/dbus-1/system.d path #
	mv "${ED}/$(python_get_sitedir)"/etc "${ED}" || die

	dosym -r /usr/share/applications/"${PN}".desktop \
		/etc/xdg/autostart/"${PN}".desktop
}
