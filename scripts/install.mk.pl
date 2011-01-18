#!/usr/bin/perl -w

$page = shift;
$lang = shift;
#@formats = ('html', 'pdf');
@formats = ('html');

@path = grep chomp, <STDIN>;
$site = shift @path;
$path = join '/', @path;

foreach $format (@formats) {
    $source = "$page.$lang.$format";
    $destination = "\$(destination_dir)/$site/$lang/$path.$format";

    print <<END;
### $source -> $destination ###

.deps/install-pages: $destination

$destination: $source \$(script_dir)/install.mk.pl
\tinstall -D \$< \$@

END
}
