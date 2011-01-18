. "./$2" || exit 1

cat << EOF
<!DOCTYPE html>
<!-- refer to http://dev.w3.org/html5/spec/Overview.html
    for more details about HTML5 -->

<!--BEGIN HEADER-->
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <link rel="stylesheet" type="text/css" href="http://style.pavlix.net/style.css">
    <title>$PAGE_TITLE</title>
    <meta name="description" content="$PAGE_DESCRIPTION">
    <meta name="keywords" content="$PAGE_KEYWORDS">
</head>
<body>
<div id="container">
<div id="header">
</div>
<!--END HEADER-->
<!--BEGIN MIDDLE-->
<div id="main">
<!--END MIDDLE-->
EOF

echo
awk -f "$webtooldir/scripts/wiki2html.awk" "$1" || exit 1
echo

if [ -z "$PAGE_COPYRIGHT" ]; then
    PAGE_COPYRIGHT="All rights reserved"
fi

cat << EOF
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

<!--
Generated: `date`
Modified: `stat "$1" -c %y`
License: $PAGE_COPYRIGHT
Path: $3
Display-Path: $4
-->

EOF
