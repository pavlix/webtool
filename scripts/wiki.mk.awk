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
END {
    printf "tag_%s_%s = %s\n", lang, name, tag
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
