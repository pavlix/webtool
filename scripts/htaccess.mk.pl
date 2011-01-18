#!/usr/bin/perl

print <<END;
include config.mk

.deps/pages:
\ttouch \$@

END

while (<STDIN>) {
    chomp;
    print <<END;
### $_ ###

.deps/htaccess: .htaccess

.htaccess: $(source_dir)/.htaccess
\tcp $< $@

END
}
