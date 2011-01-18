#!/usr/bin/perl

sub initial_rules { print <<END; }
include config.mk

.deps/pages: .deps/languages pages.mk
\ttouch \$@
.deps/install-pages: .deps/pages
\ttouch \$@
.deps/languages: pages.mk
\tmkdir -p .deps
\ttouch \$@

END

sub page_rules { my $file = join '.', @_; my $page = shift; my $lang = shift; my $format = shift; print <<END; }
### $file ###

#.deps/pages: $page.$lang.html $page.$lang.pdf $page.$lang.tag $page.$lang.name $page.$lang.path $page.$lang.displaypath $page.$lang.mk

targets = $page.$lang.html $page.$lang.tag $page.$lang.name $page.$lang.path $page.$lang.displaypath $page.$lang.mk

.deps/pages: \$(targets)
\$(targets): pages.mk

$page.$lang.html: \$(source_dir)/$file $page.$lang.path \$(script_dir)/wiki2html.pl #pages.mk
\t\$(script_dir)/wiki2html.pl \$< $page.$lang.path $page.$lang.displaypath > \$@

$page.$lang.pdf: $page.$lang.ps
\tps2pdf \$< \$@

$page.$lang.ps: $page.$lang.html
\thtml2ps -e utf-8 \$< > \$@

include $page.$lang.mk
$page.$lang.mk: $page.$lang.path \$(script_dir)/install.mk.pl
\t\$(script_dir)/install.mk.pl $page $lang < \$< > \$@

END

sub index_rules { my $file = join '.', @_; my $page = shift; my $lang = shift; my $format = shift; print <<END; }
# index

$page.$lang.path: path.$lang
\tcat \$< > \$@
\techo index >> \$@

$page.$lang.displaypath: displaypath.$lang
\tcat \$< > \$@

$page.$lang.name: \$(source_dir)/$file pages.mk \$(script_dir)/page-name.pl
\t\$(script_dir)/page-name.pl \$(dir_name) < \$< > \$@

$page.$lang.tag: \$(source_dir)/$file pages.mk \$(script_dir)/page-tag.pl
\t\$(script_dir)/page-tag.pl \$(dir_name) < \$< > \$@

END

sub nonindex_rules { my $file = join '.', @_; my $page = shift; my $lang = shift; my $format = shift; $format, print <<END; }
# nonindex

$page.$lang.path: path.$lang $page.$lang.tag
\tcat \$< $page.$lang.tag > \$@

$page.$lang.displaypath: displaypath.$lang $page.$lang.name
\tcat \$< $page.$lang.name > \$@

$page.$lang.name: \$(source_dir)/$file pages.mk \$(script_dir)/page-name.pl
\t\$(script_dir)/page-name.pl $page < \$< > \$@

$page.$lang.tag: \$(source_dir)/$file pages.mk \$(script_dir)/page-tag.pl
\t\$(script_dir)/page-tag.pl $page < \$< > \$@

END

sub language_rules { my $lang = shift; print <<END; }
### Language: $lang ###

.deps/languages: path.$lang displaypath.$lang
path.$lang: path.$lang.parent index.$lang.tag pages.mk
\tcat path.$lang.parent index.$lang.tag > \$@
displaypath.$lang: displaypath.$lang.parent index.$lang.name pages.mk
\tcat displaypath.$lang.parent index.$lang.name > \$@

END

sub language_rules_fake_parent { my $lang = shift; print <<END; }
path.$lang.parent: path pages.mk
\thead -n -1 \$< > \$@

displaypath.$lang.parent: path pages.mk
\thead -n -1 \$< > \$@

END

sub final_rules {}

open(PAGES, "<", shift); @pages = grep chomp, <PAGES>; close(PAGES);
open(LANG, "<", shift); @languages = grep chomp, <LANG>; close(LANG);
open(PAR, "<", shift); @parent_languages = grep chomp, <PAR>; close(PAR);

my $index = 0;
initial_rules;
foreach (@languages) {
    my $language = $_;
    language_rules $language;
    next if grep $_ == $language, @parent_languages;
    language_rules_fake_parent $language;
}
#my %page_languages;
foreach (@pages) {
    chomp;
    @info = split /\./, $_;
    ($page, $lang, $format) = @info;
    #$page_languages{$page} = $lang;
    grep $lang, @languages || next;
    page_rules @info;
    if ($page =~ 'index') {
        index_rules @info;
    }
    else {
        nonindex_rules @info;
    }
}
final_rules;
