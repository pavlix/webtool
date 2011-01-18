#!/usr/bin/perl -w

print <<END;
include config.mk

.deps/recursive:

.deps/subdirs:
\ttouch \$@

.deps/install-recursive: .deps/subdirs

END

sub subdir_rules { print <<END; }
### $_ ###

.deps/subdirs: $_/Makefile $_/config.mk $_/path $_/languages.parent
.deps/recursive: .deps/recursive-$_
.deps/install-recursive: .deps/install-recursive-$_

$_/Makefile: Makefile
\tmkdir -p $_
\tcp \$< \$@

$_/config.mk: config.mk subdirs.mk
\tmkdir -p $_
\techo 'script_dir = \$(script_dir)' > \$@
\techo 'source_dir = \$(source_dir)/$_' >> \$@
\techo 'destination_dir = \$(destination_dir)' >> \$@
\techo 'dir_name = $_' >> \$@

$_/path: path subdirs.mk
\tmkdir -p $_
\tcat \$< > \$@
\techo $_ >> \$@

$_/languages.parent: languages
\tcp \$< \$@

.deps/recursive-$_:
\tmake -r -C $_ all

.deps/install-recursive-$_:
\tmake -r -C $_ install

END

sub language_rules {
    $subdir = shift;
    $language = shift;
    print <<END;

### $subdir $language ###

.deps/subdirs: $subdir/path.$language.parent $subdir/displaypath.$language.parent
$subdir/path.$language.parent: path.$language
\tcp \$< \$@
$subdir/displaypath.$language.parent: displaypath.$language
\tcp \$< \$@

END
}

open(DIR, "<", $ARGV[0]); @subdirs = grep chomp, <DIR>; close(DIR);
open(LANG, "<", $ARGV[1]); @languages = grep chomp, <LANG>; close(LANG);

foreach (@subdirs) {
    subdir_rules;
    my $dir = $_;
    foreach (@languages) {
        language_rules $dir, $_;
    }
}
