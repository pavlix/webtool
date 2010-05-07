BEGIN {
    print "include languages.mk"
    print "languages.mk: .languages $(webtooldir)/scripts/languages.mk.awk"
    print "\t" "awk -f $(webtooldir)/scripts/languages.mk.awk $< > $@"
}
function build_meta(build_meta_file, source_wiki_file) {
    print build_meta_file ":", source_wiki_file, "$(webtooldir)/scripts/wiki2meta.awk", "site.mk"
    print "\t" "awk -f $(webtooldir)/scripts/wiki2meta.awk $< > $@"
}
function build_make(build_make_file, build_meta_file) {
    printf "include %s\n", build_make_file
    printf "site: %s\n", build_make_file
    printf "%s: %s $(webtooldir)/scripts/wiki.mk.awk\n", build_make_file, build_meta_file
    printf "\t" "awk -v name=%s -v lang=%s -f $(webtooldir)/scripts/wiki.mk.awk $< > $@\n", name, lang
}
$1 ~ /^-/ && $9 ~ /\.wiki$/ {
    print "#", "Wikitext:", $9
    # parse input
    split($9, a, /\./)
    len = length(a)
    print "#", "Number of components:", len
    name = a[1]
    lang = a[2]
    langext = "." lang
    ext = "." a[3]
    source_wiki_file = "$(sourcedir)/$(path)/" name langext ext
    build_html_file = name langext ".html"
    build_meta_file = name langext ".meta"
    build_make_file = name langext ".mk"
    scripts = "$(webtooldir)/scripts/*"
    # makefile
    build_make(build_make_file, build_meta_file)
    # html file
    print "site: " build_html_file
    print build_html_file ":", source_wiki_file, build_meta_file ".sh", scripts
    print "\t" "sh $(webtooldir)/scripts/page.sh $<", build_meta_file ".sh", "> $@"
    # meta shell script
    printf "%s.sh: %s $(webtooldir)/scripts/meta.sh.awk\n", build_meta_file, build_meta_file
    printf "\t" "awk -f $(webtooldir)/scripts/meta.sh.awk $< > $@\n"
    #awk -f "$webtooldir/scripts/meta.sh.awk" "$2"
    # meta file
    build_meta(build_meta_file, source_wiki_file)
    # record languages
    languages[lang] = 1
    if (name == "index") {
        index_languages[lang] = 1
    }
    next
}
/^d/ && $9 ~ /^[A-Za-z0-9]*$/ {
    print "#", "Directory:", $9
    # parse input
    name = $9
    # install subdirectories
    print "do-install: do-install-" name
    print "do-install-" name ":"
    print "\t" "mkdir -p", name
    print "\t" "make -C", name, "install"
    # make subdirectories with virtual dependency
    printf "site: %s/.virtual.makefiles\n", name
    printf "%s/.virtual.makefiles: %s/Makefile %s/config.mk %s/parent.mk\n", name, name, name, name
    #printf "\t" "cd %s && make\n", name
    printf "\t" "make -C %s\n", name
    #printf "\t" "> $@\n"
    # Makefile
    print name "/Makefile:", "$(webtooldir)/makefile.mk"
    print "\t" "mkdir -p `dirname $@`"
    print "\t" "cp $< $@"
    # parent includes
    print name "/config.mk: config.mk"
    print "\t" "cp $< $@"
    dirs[ndirs++] = name
    next
}
END {
    print "#", "END"
    #printf "site:"
    #for (i = 0; i < n; i++) {
    #    printf " %s/Makefile %s/", dirs[i]
    #}
    #printf "\n"
    #for (i = 0; i < n; i++) {
    #    print "\t" "make -C", dirs[i]
    #}
    #print ""
    #print "do-install:"
    #print "\t", "echo $^"
    # set languages variable in makefile
    printf "languages ="
    for (lang in languages) {
        printf " %s", lang
    }
    printf "\n"
    # save languages into .languages
    print ".languages: .dep.tags .dep.install"
    print "\t" "> $@"
    for (lang in languages) {
        printf "\t" "echo '[%s]' >> $@\n", lang
        printf "\t" "echo -n 'Tag: ' >> $@\n"
        printf "\t" "cat .tag.%s >> $@\n", lang
    }

    print "do-install:"
    #print "\t" "echo 'Installed.'"
    print ".dep.tags:"
    print "\t" "> $@"
    print ".dep.install:"
    print "\t" "> $@"

    for (lang in languages) {
        if (lang) {
            langext = "." lang
        }
        else {
            langext = ""
        }
        printf ".dep.tags: .tag%s\n", langext
        #printf ".dep.install: .install.%s\n", lang
        #printf "do-install: do-install-%s", lang, lang
        #printf ".install.%s: .listing .tag.%s $(webtooldir)/scripts/install.awk\n", lang, lang
        #printf "\t" "awk -v lang=%s -v tag=`<.tag.%s`", lang, lang
        #print " -f $(webtooldir)/scripts/install.awk $< > $@\n"

        if (!(lang in index_languages)) {
            build_meta("index" langext ".meta", "/dev/null")
        }
        default_tag="`echo $(path) | sed 's/^.*\\///'`"
        print ".tag" langext ":", "index" langext ".meta", "$(webtooldir)/scripts/var.awk site.mk"
        print "\t" "awk -v select=Tag",
            "-v default=" default_tag, "-f $(webtooldir)/scripts/var.awk $< > $@"
        #}
        #else {
        #    print ".tag." lang ": site.mk"
        #    print "\t" "echo", default_tag, "> $@"
        #}
    }

    for (i = 0; i < ndirs; i++) {
        name = dirs[i]
        print name "/parent.mk: site.mk languages.mk"
        print "\t" "> $@"
        print "\t" "echo parentpath = $(path) >> $@"
        print "\t" "echo currentdir =", name, " >> $@"
        for (lang in languages) {
            printf "\t" "echo parentpath_%s = $(path_%s) >> $@\n", lang, lang
        }
    }
}
