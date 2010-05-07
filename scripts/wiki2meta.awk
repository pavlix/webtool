# This script extracts variables from wikifile's metadata
# and outputs a shell script.
#
# Example syntax:
# .meta {{{
# Tag: sometag
# Name: somename
# }}}

BEGIN {
    FS = ":"
}
!metasection && /^= / {
    if (!"Name" in vars) {
        sub(/^= */, "")
        sub(/ *=?$/, "")
        vars["Name"] = $0
    }
    next
}
!metasection && /^\.meta *{{{/ {
    metasection = 1
    next
}
metasection && /^}}}/ {
    metasection = 0
    next
}
metasection && /^[ \t]*(#|$)/ {
    next
}
metasection {
    print
}
