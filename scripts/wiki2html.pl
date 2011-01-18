#!/usr/bin/perl -w
use POSIX qw(strftime);

$filename = shift;
open PATH, '<', shift;
open DISPLAY_PATH, '<', shift;
@path = grep chomp, <PATH>; close PATH;
@display_path = grep chomp, <DISPLAY_PATH>; close DISPLAY_PATH;

($name, $lang, $format) = split /\./, $filename;

$path_markup = "";
for ($i = 0; $i < @display_path; $i++) {
    $path = (join '/', @path[0..$i]) . ($i == @path-1 ? '' : '/');
    $i && ($path_markup .= " » ");
    $path_markup .= "<a href=\"/$lang/$path\">$display_path[$i]</a>";
}

$path = join '/', @path;
$display_path = join ' » ', @display_path;
$generated = strftime "%Y-%m-%d %H:%M:%S %z", localtime;

# DOCTYPE & debugging data
print <<END;
<DOCTYPE html>
<!-- refer to http://dev.w3.org/html5/spec/Overview.html for more details about HTML5 -->

<!--
Generated: $generated
Filename: $filename
Path: %s
Display-Path: %s
Path Markup: $path_markup
-->

END

# Header
print <<END;

<!--BEGIN HEADER-->
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <link rel="stylesheet" type="text/css" href="/style.css">
    <title>$PAGE_TITLE</title>
    <meta name="description" content="$PAGE_DESCRIPTION">
    <meta name="keywords" content="$PAGE_KEYWORDS">
</head>
<body>
    <div id="container"><!--<div id="header"></div>--><div id="main">
            <p class="navigation_path">$path_markup</p>
<!--END HEADER-->

END

sub process_markup {
    my %dict = %{$_[0]};
    my $mark = $dict{'mark'};
    print STDERR "  MARK $mark\n";
    my $text = $dict{text};
    if ($mark eq '//') {
        return "<em>" . process_text($text) . "</em>";
    }
    elsif ($mark eq '[[') {
        my $link = $dict{'link'};
        my $prefix = $dict{'prefix'};
        if ($text eq '') {
            $text = $link;
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
    $text =~ s/(
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
    print STDERR "  RETURN TEXT $text\n";
    return $text;
}

sub process_paragraph {
    $text = shift;
    print STDERR "  PARA $text\n";
    $text =~ s/^\s*//;
    $text =~ s/^\s+/ /g;
    $text =~ s/\s*$//;
    $text = process_text $text;
    $text =~ s/(.*)/<p>$1<\/p>/;
    $text =~ s/(.{1,79}\S|\S+)\s+/$1\n/g;
    $text =~ s/\n*$/\n\n/;
    print STDERR "  RETURN PARA $text\n";
    return $text;
}

open SOURCE, '<', $filename;
print "<!--BEGIN CONTENT-->\n\n";
$list_level = 0;
$comment = 0;
while (<SOURCE>) {
    #print STDERR "  LINE $_";
    chomp;
    if ($comment) {
        if (/^\]\]\]$/) {
            $comment = 0;
        }
        next;
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
        print STDERR "  H$c $_\n";
        print "<h$c>$_</h$c>\n\n";
        next;
    }
    # list
    if (!$paragraph && /^\*+ /) {
        $last_list_level = $list_level;
        $list_level = 0;
        while (s/^\*//) { $list_level++ };
        s/^\s*//;
        s/\s*$//;
        if ($last_list_level == $list_level) {
            print "</li>\n";
        }
        while ($last_list_level < $list_level) {
            $last_list_level && print "<li>";
            print "\n<ul>\n";
            $last_list_level++;
        }
        while ($last_list_level > $list_level) {
            print "\n</li>\n</ul>\n";
            $last_list_level--;
            if ($last_list_level == $list_level) {
                print "</li>\n";
            }
        }
        print "<li>" . process_text $_;
        next;
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
    if ($paragraph && /^\s*$/) {
        print process_paragraph $paragraph;
        $paragraph = '';
        next;
    }
    if (/^\[\[\[comment$/) {
        $comment = 1;
        next;
    }
    # inside paragraph
    $paragraph .= ' ';
    $paragraph .= $_;
}
print process_paragraph $paragraph;

close SOURCE;
print "<!--END CONTENT-->\n\n";

# Footer
print <<END;
<!--BEGIN FOOTER-->
        </div>
    </div>
<div id="footer">
Copyright © 2010 <a href="http://www.pavlix.net/">pavlix</a><br>
${PAGE_COPYRIGHT}
</div>
</body>
</html>
<!--END FOOTER-->
END
