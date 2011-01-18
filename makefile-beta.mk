makefiles = Makefile config.mk

include config.mk

all: .deps/recursive .deps/htaccess
this: .deps/subdirs .deps/htaccess
install: subdirs.mk install-pages
	make -r -f subdirs.mk .deps/install-recursive
install-pages: pages.mk
	make -r -f pages.mk .deps/install-pages

.deps/recursive: subdirs.mk .deps/subdirs
	make -r -f $< .deps/recursive

.deps/subdirs: subdirs.mk .deps/pages
	make -r -f $< .deps/subdirs

#.deps/languages: languages.mk
#	make -r -f $< .deps/languages

.deps/pages: pages.mk $(script_dir)/*
	make -r -f $< .deps/pages

.deps/htaccess: htaccess.mk
	make -r -f $<

subdirs.mk: subdirs languages $(script_dir)/subdirs.mk.pl
	$(script_dir)/subdirs.mk.pl $< languages > $@

subdirs: $(source_dir) $(makefiles)
	( cd $(source_dir) && perl -e 'print grep -d && s/$$/\n/, <*>;'; ) > $@

pages.mk: pages languages languages.parent $(script_dir)/pages.mk.pl
	$(script_dir)/pages.mk.pl $< languages languages.parent > $@

pages: $(source_dir) $(makefiles)
	( cd $(source_dir) && perl -e 'print grep -f && /\.wiki$$/ && s/$$/\n/, <*>;'; ) > $@

#languages.mk: languages languages.parent $(script_dir)/languages.mk.pl
#	$(script_dir)/languages.mk.pl languages languages.parent > $@

languages: $(source_dir) $(makefiles)
	( cd $(source_dir) && perl -e 'print grep -f && s/\.wiki$$//g && s/^index\.// && s/$$/\n/, <*>;'; ) | sort -u > $@

htaccess.mk: htaccess $(script_dir)/htaccess.mk.pl
	$(script_dir)/htaccess.mk.pl < $< > $@

htaccess: $(source_dir) $(makefiles)
	( cd $(source_dir) && perl -e 'print grep -f && /\.htaccess$$/ && s/$$/\n/, <*>;'; ) > $@
