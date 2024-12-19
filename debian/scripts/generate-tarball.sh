#!/bin/bash

set -e -u

if [ ! -d debian ]; then
	echo "Couldn't find debian/ directory."
	exit 1
fi

PKGNAME=$(dpkg-parsechangelog -S Source)
VERSION=$(dpkg-parsechangelog | grep -E '^Version:' | cut -f 2 -d ' ' \
    | cut -f -1 -d '-')
KERNEL_VERSION=$(grep -oP "KERNEL_VERSION = linux-\K.*" Makefile)

fakeroot ./debian/rules clean

if [ ! -f "tarballs/linux-${KERNEL_VERSION}.tar.xz" ]; then
	mkdir -p tarballs
	curl "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${KERNEL_VERSION}.tar.xz" \
	    -o "tarballs/linux-${KERNEL_VERSION}.tar.xz"
fi

tar -czf "../${PKGNAME}_${VERSION}.orig.tar.gz" \
    --exclude ".git" --exclude "debian" \
    --xform "s/^\./${PKGNAME}-${VERSION}/" .
