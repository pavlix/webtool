#!/usr/bin/perl -w
while (<STDIN>) {
    /^\s*$/ && last;
    s/^Tag: // && print && exit;
}
print "$ARGV[0]\n";
