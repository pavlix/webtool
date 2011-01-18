#!/usr/bin/perl -w
while (<STDIN>) {
    /^\s*$/ && last;
    s/^Name: // && print && exit;
}
while (<STDIN>) {
    s/^= // && print && exit;
    /^\s*/ || last;
}
print "$ARGV[0]\n";
