test "$destdir" || { echo "Destination directory required." >&2; exit 1; }
test "$syncdir" || { echo "Destination directory required." >&2; exit 1; }

rsync_flags="-avz" # --delete"
echo rsync $rsync_flags "$destdir/" "$syncdir"
rsync $rsync_flags "$destdir/" "$syncdir"
