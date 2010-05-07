BEGIN {
    FS = ":"
}
/^[A-Za-z0-9_-]*:/ {
    # get name and value
    name = $1
    value = $0
    sub(/^[^:]*: */, "", value)
    print value
    # escape value and print a shell variable assignment
    gsub(/\\/, "\\\\", value)
    gsub(/`/, "\\`", value)
    gsub(/\$/, "\\$", value)
    gsub(/"/, "\\\"", value)
    print "export", "PAGE_" toupper(name) "=\"" value "\""
}
