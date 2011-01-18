test "$builddir" || { echo "Build directory required." >&2; exit 1; }
test "$destdir" || { echo "Destination directory required." >&2; exit 1; }

mkdir -p "$builddir"
mkdir -p "$destdir"

cat << EOF > $builddir/config.mk || exit 1
webtooldir = $webtooldir
sourcedir = $sourcedir
builddir = $builddir
destdir = $destdir

script_dir = /home/pavlix/src/webtool/scripts
source_dir = $sourcedir
destination_dir = $destdir
level = 0
EOF

cat << EOF > $builddir/parent.mk || exit 1
parentpath = .
currentdir = .
EOF

> $builddir/languages.parent
> $builddir/path

cp $webtooldir/makefile-beta.mk $builddir/Makefile || exit 1
