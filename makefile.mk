path = $(parentpath)/$(currentdir)

include config.mk
include parent.mk

.PHONY: all install clean dirs
all: Makefile config.mk parent.mk site
#clean:
#	rm -rf $(builddir)
install: site.mk do-install
uninstall: site.mk do-uninstall

site: site.mk .dep.install

Makefile: $(webtooldir)/makefile.mk
	cp $< $@
site.mk: .listing $(webtooldir)/scripts/site.mk.awk
	awk -f $(webtooldir)/scripts/site.mk.awk $< > $@
.listing: $(sourcedir)/$(path) Makefile
	LANG=C ls -la $< > $@

include site.mk

#meta.mk: .listing $(webtooldir)/scripts/meta.mk.awk
#	awk -f $(webtooldir)/scripts/meta.mk.awk < $< > $@
    
