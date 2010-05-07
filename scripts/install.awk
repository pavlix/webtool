$1 ~ /^-/ && $9 ~ /\.wiki$/ {
    split($9, a, /\./)
    name = a[1]
    if (lang == a[2]) {
        files[name "." lang ".html"] = "$destdir/" lang "/$path_" lang "/" name ".html"
    }
}
END {
    print "if [ ! \"$destdir\" ]; then"
    print "    echo \"Variable destdir is not set!\" >&2"
    print "    exit 1"
    print "fi"
    print ""

    print "tag=" tag
    print "path_" lang "=$path_" lang "/$tag"

    print ""
    for (file in files) {
        print "install -m 644", file, files[file]
    }
}
