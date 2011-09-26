#!/usr/bin/perl -w
use POSIX qw(strftime);
use Time::HiRes qw (time);

$time = time();

$filename = shift;
open PATH, '<', shift;
open DISPLAY_PATH, '<', shift;
@path = grep chomp, <PATH>; close PATH;
@display_path = grep chomp, <DISPLAY_PATH>; close DISPLAY_PATH;

($name, $lang, $format) = split /\./, $filename;

$path_markup = "";
for ($i = 0; $i < @display_path; $i++) {
    $path = (join '/', @path[1..$i]) . (($i == (@path-1) or $i == 0) ? '' : '/');
    $i && ($path_markup .= " » ");
    $path_markup .= "<a href=\"/$lang/$path\">$display_path[$i]</a>";
}

$path = join '/', @path;
$display_path = join ' » ', @display_path;
$generated = strftime "%Y-%m-%d %H:%M:%S %z", localtime;

$copyright = "";
# DOCTYPE & debugging data
print <<END;
<DOCTYPE html>
<!-- refer to http://dev.w3.org/html5/spec/Overview.html for more details about HTML5 -->

<!--
Generated: $generated
Name: $name
Lang: $lang
Format: $format
Path: $path
Display-Path: $display_path
Path Markup: $path_markup
-->

END

# Header
# TODO title, description, keywords
print <<END;

<!--BEGIN HEADER-->
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <link rel="stylesheet" type="text/css" href="http://style.pavlix.net/style.css">
    <title></title>
    <meta name="description" content="">
    <meta name="keywords" content="">
</head>
<body>
    <div id="container"><!--<div id="header"></div>--><div id="main">
            <p class="navigation_path">$path_markup</p>
<!--END HEADER-->

END

sub process_markup {
    my %dict = %{$_[0]};
    my $mark = $dict{'mark'};
    #print STDERR "  MARK $mark\n";
    my $text = $dict{text};
    if ($mark eq '//') {
        return "<em>" . process_text($text) . "</em>";
    }
    elsif ($mark eq '**') {
	return "<strong>" . process_text($text) . "</strong>";
    }
    elsif ($mark eq '##') {
        return "<code>$text</code>";
    }
    elsif ($mark eq '[[') {
        my $link = $dict{'link'};
        my $prefix = $dict{'prefix'} || "";
        if ($text eq '') {
            $text = $link;
        }
        if ($prefix eq 'rfc:') {
            $prefix = "http:";
            $link = "//tools.ietf.org/html/rfc$link";
            $text = "RFC $text";
        }
        return "<a href=\"$prefix$link\">$text</a>";
    }
    else {
        return "ERROR($mark$text)";
    }
}

sub process_text {
    $text = shift;
    #print STDERR "  PROCESS TEXT $text\n";
    $text =~ s/~ / /g;
    $text =~ s/(
            (?<mark>\*\*)(?<text>.*?)\*\*|
            (?<mark>\/\/)(?<text>.*?)\/\/|
            (?<mark>\#\#)(?<text>.*?)\#\#|
            (?<mark>\[\[)
                (?<prefix>.+?:)?
                (?<link>.+?)
                (?:\|(?<text>.+?))?
                \]\])
        /
            process_markup(\%+);
        /gxe;
    #print STDERR "  RETURN TEXT $text\n";
    return $text;
}

sub process_paragraph {
    $text = shift;
    #print STDERR "  PARA $text\n";
    $text =~ s/^\s*//;
    $text =~ s/^\s+/ /g;
    $text =~ s/\s*$//;
    $text = process_text $text;
    $text =~ s/(.*)/<p>$1<\/p>/;
    $text =~ s/(.{1,79}\S|\S+)\s+/$1\n/g;
    $text =~ s/\n*$/\n\n/;
    #print STDERR "  RETURN PARA $text\n";
    return $text;
}

open SOURCE, '<', $filename;
# skip headers
$backslash = 0;
while (<SOURCE>) {
    /[a-zA-Z_-]+\: ./ or $backslash or last;
    $backslash = 0;
    if (/[^\\]\\$/) { $backslash = 1 }
}
print "<!--BEGIN CONTENT-->\n\n";
$list_level = 0;
$comment = 0;
$preformatted = 0;
# parse wikitext
sub parse_line {
    $_ = shift;
    #print STDERR "  LINE $_";
    if ($comment) {
        if (/^\]\]\]$/) {
            $comment = 0;
        }
        return;
    }
    if ($preformatted) {
        if (/^}}}$/) {
            $preformatted = 0;
            print "</pre>\n";
        }
        else {
	    print "$_\n";
        }
        return;
    }
    # erase escaped newlines
    while (/[^\\](\\\\)*\\$/) {
        s/\\$//;
        $_ .= <SOURCE>;
        #print STDERR "  LINE $_";
        chomp;
    }
    # headlines
    if (/^=+ /) {
        my $c = 0;
        while (s/^=//) { $c++; }
        s/^ *//;
        s/ *=*$//;
        #print STDERR "  H$c $_\n";
        print "<h$c>$_</h$c>\n\n";
        return;
    }
    # list
    if (!$paragraph && /^\*+ /) {
        $last_list_level = $list_level;
        $list_level = 0;
        while (s/^\*//) { $list_level++ };
        s/^\s+//;
        s/\s+$//;
        if ($last_list_level == $list_level) {
            print "</li>\n";
        }
        while ($last_list_level < $list_level) {
	    $indent = "    "x $last_list_level;
            print "<ul>\n";
            $last_list_level++;
        }
        while ($last_list_level > $list_level) {
            $last_list_level--;
	    $indent = "    "x $last_list_level;
            print "</li>\n$indent</ul>";
            if ($last_list_level == $list_level) {
                print "</li>\n";
            }
        }
	$indent = "    "x $list_level;
        print $indent, "<li>", process_text $_;
        return;
    }
    # end of list
    if ($list_level && /^\s*$/) {
        while ($list_level > 1) {
            print "\n</li></ul>\n";
            $list_level--;
        }
        print "</li>\n</ul>\n\n";
        $list_level--;
    }
    # end of paragraph
    if (/^\s*$/) {
	if ($paragraph) {
	    print process_paragraph $paragraph;
	}
        $paragraph = '';
        return;
    }
    if (/^\[\[\[comment$/) {
        $comment = 1;
        return;
    }
    if (/^{{{$/) {
        $preformatted = 1;
        print "<pre>\n";
        return;
    }
    # inside paragraph
    s/ *\\\\$/<br>/;
    $paragraph .= ' ';
    $paragraph .= $_;
}
while (<SOURCE>) {
    chomp;
    parse_line("$_");
}
parse_line("");

close SOURCE;
print "<!--END CONTENT-->\n\n";

# Footer
print <<END;
<!--BEGIN FOOTER-->
        </div>
    </div>
<div id="footer">
Copyright © 2010 <a href="http://www.pavlix.net/">pavlix</a><br>
${copyright}
</div>
</body>
</html>
<!--END FOOTER-->
END

printf STDERR "wiki2html: %s generated in %.4f seconds.\n", $name, time() - $time;
