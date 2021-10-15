fetch_debian() {
	pushd "${S}" 1>/dev/null
		ebegin "Downloading $1.debian.tar.xz"
			wget -q "https://launchpad.net/ubuntu/+archive/primary/+files/$1.debian.tar.xz" -O "$1.debian.tar.xz"
			b2sum --status -c <(echo "$2 $1.debian.tar.xz") || die "b2sum: checksum did not match"
		eend
		unpack "${S}/$1.debian.tar.xz"
	popd 1>/dev/null
}
