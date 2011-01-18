BEGIN {
    FS = ": *"
}
/^\[[a-z]*\]$/ {
    sub(/^\[/, "")
    sub(/\]$/, "")
    lang = $0
    print "#", "Language:", lang
    printf "path_%s = $(if $(parentpath_%s),", lang, lang
    printf "$(parentpath_%s)/$(currenttag_%s),", lang, lang
    printf "$(parentpath)/$(currenttag_%s))\n", lang
    printf "displaypath_%s = $(if $(parentdisplaypath_%s),", lang, lang
    printf "$(parentdisplaypath_%s)/$(displayname_%s_index),", lang, lang
    printf "$(parentpath)/$(displayname_%s_index))\n", lang
    #printf ".tags.%i: $(sourcedir)/$(path)/index.%i.meta", lang, lang
    #printf "\t" ...
    next
}
lang && $1 == "Tag" {
    printf "currenttag_%s = %s\n", lang, $2
    next
}
{
    print "#", "Ignored:", $0
}
