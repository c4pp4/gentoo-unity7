fetch_debian() {
	ebegin "Downloading $1.debian.tar.xz"
		wget -q "https://launchpad.net/ubuntu/+archive/primary/+files/$1.debian.tar.xz" -O "${WORKDIR}/debian.tar.xz"
		b2sum --status -c <(echo "$2 debian.tar.xz") || die "b2sum: checksum did not match"
	eend
	unpack "${WORKDIR}/debian.tar.xz"
}
