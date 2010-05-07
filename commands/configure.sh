test "$builddir" || { echo "Build directory required." >&2; exit 1; }
test "$destdir" || { echo "Destination directory required." >&2; exit 1; }

mkdir -p "$builddir"
mkdir -p "$destdir"

cat << EOF > $builddir/config.mk || exit 1
webtooldir = $webtooldir
sourcedir = $sourcedir
builddir = $builddir
destdir = $destdir
EOF

cat << EOF > $builddir/parent.mk || exit 1
parentpath = .
currentdir = .
EOF

cp $webtooldir/makefile.mk $builddir/Makefile || exit 1
