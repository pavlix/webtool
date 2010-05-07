# This script extracts a variable from an INI-like file.
#
# Input variable: select -- name of the variable

BEGIN {
    FS = ":"
}
$1 == select && NF > 1 {
    sub(/^[^:]*:[ \t]*/, "")
    value = $0;
}
END {
    if (value) {
        print value
    }
    else {
        print default
    }
}
