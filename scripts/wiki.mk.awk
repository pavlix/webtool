# Input variables:
#   name
#   lang
BEGIN {
    tag = name
}
name != "index" && /^Tag:/ {
    sub(/^Tag: */, "")
    tag = $0
}
/^Name:/ {
    sub(/^Name: */, "")
    gsub(/\\/, "\\\\")
    gsub(/\$/, "\\$")
    gsub(/\"/, "\\\"")
    display_name = $0
}
END {
    printf "tag_%s_%s = %s\n", lang, name, tag
    printf "displaypath_%s_%s = $(displaypath_%s)/$(displayname_%s_%s)\n", lang, name, lang, lang, name
    if (display_name) {
        printf "displayname_%s_%s = \"%s\"\n", lang, name, display_name
    }
    else {
        printf "displayname_%s_%s = $(currentdir)\n", lang, name
    }
    printf "all: %s.%s.displaypath\n", name, lang
    printf "%s.%s.displaypath: %s.%s.mk\n", name, lang, name, lang
    printf "\t" "echo $(displaypath_%s_%s) >$@\n", lang, name
    build_make_file = name "." lang ".mk"
    build_html_file = name "." lang ".html"
    output_html_file = "$(destdir)/" lang "/$(path_" lang ")/$(tag_" lang "_" name ").html"
    # install
    print "do-install:", output_html_file
    print output_html_file ":", build_html_file, build_make_file
    print "\t" "mkdir -p `dirname $@`"
    print "\t" "cp $< $@"
    # uninstall
    print "do-uninstall:", "do-uninstall-" output_html_file
    print "do-uninstall-" output_html_file ":"
    print "\t" "rm", output_html_file
}
