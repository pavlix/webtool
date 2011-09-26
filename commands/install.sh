test "$builddir" || { echo "Build directory required." >&2; exit 1; }
test "$destdir" || { echo "Destination directory required." >&2; exit 1; }

rm -rf "$destdir" || exit 1
mkdir "$destdir" || exit 1
cd "$builddir"
make install

. "$sourcedir/.webtool/hooks/postinst.sh"
