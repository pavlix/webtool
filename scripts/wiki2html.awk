#!/bin/awk --exec
#
# This script has been put into public domain according to
# http://creativecommons.org/publicdomain/zero/1.0/
#
# May be used standalone

BEGIN {
    context = ""
    listlevel = 0
}
END {
    set_context("")
}

function parse_text(text) {
    text = gensub(/\[\[([^\[\]]*)\|([^\[\]]*)\]\]/, "<a href=\"\\1\">\\2</a>", "g", text)
    text = gensub(/\[\[([^@/: ]*)@([^@/: ]*)\]\]/, "<a href=\"mailto:\\1@\\2\">\\1@\\2</a>", "g", text)
    text = gensub(/\/\/([^\/]+(\/[^\/]+)*)\/\//, "<em>\\1</em>", "g", text)
    text = gensub(/\*\*([^\*]+(\/[^\*]+)*)\*\*/, "<strong>\\1</strong>", "g", text)
    text = gensub(/--([^ \t-]+(([ \t]*|-)[^ \t-]+)*)--/, "<del>\\1</del>", "g", text)
    gsub(/--/, "\\&#x2013;", text)
    text = gensub(/\\\\/, "<br>", "g", text)
    text = gensub(/~ /, "\\&#x00a0;", "g", text)
    gsub(/@/, "\\&#x0040;", text)
    return text 
}
function set_context(newcontext) {
    if (context == newcontext) { return 0 }
    if (context == "para") { para_end() }
    else if (context == "list") { list_end() }
    if (newcontext == "para") { para_start() }
    else if (newcontext == "list") { list_start() }
    context = newcontext
    return 1
}
function indent(n,  whitespace) {
    whitespace = ""
    for (i = 0; i < n; i++) { whitespace = whitespace "    " }
    return whitespace
}
function set_list_level(newlevel) {
    if (listlevel==newlevel) { printf "</li>\n%s<li>", indent(newlevel) }
    while (listlevel<newlevel) {
	printf "\n%s<ul>\n%s<li>", indent(listlevel), indent(listlevel+1)
        listlevel++
    }
    while (listlevel>newlevel) {
	printf "</li>\n%s</ul>%s\n%s",
            indent(newlevel),
            (newlevel ? "</li>" : ""),
            (newlevel ? indent(newlevel) "<li>" : "")
        listlevel--
    }
}
function para_start() {
    printf "<p>"
}
function para_end() {
    print "</p>"
    print ""
}
function list_start() {
}
function list_end() {
    set_list_level(0)
    print ""
}

/^[ \t]*$/ {
    set_context("")
    next
}

# html verbatim

/^\.html / {
    verbatim = $0
    sub(/^\.html /, "", verbatim)
    print verbatim
    next
}

# comments and meta information

/^\.meta *{{{/ {
    set_context("meta-section")
    next
}
context=="meta-section" && /^}}}/ {
    set_context("")
    next
}
context=="meta-section" {
    next
}

/^\.meta / {
    next
}

# headlines
/^=+ / {
    set_context("")
    headline = $0
    level = 0
    while(sub(/^=/, "", headline)) { level++ }
    sub(/^ */, "", headline)
    sub(/ *=* *$/, "", headline)
    print "<h" level ">" parse_text(headline) "</h" level ">"
    print ""
    next
}

# lists
/^[ \t]*\*/ {
    line = $0
    level = 0
    while(sub(/^\*/, "", line)) { level++ }
    sub(/^ */, "", line)
    set_context("list")
    set_list_level(level)
    printf "%s", parse_text(line)
    next
}
context=="list" {
    line = $0
    printf "\n%s", parse_text(line)
    next
}
# paragraphs
{
    if (!set_context("para")) printf "\n"
    printf "%s", parse_text($0)
}

