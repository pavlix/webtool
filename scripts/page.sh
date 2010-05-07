. "$2"

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
awk -f "$webtooldir/scripts/wiki2html.awk" "$1"
echo

cat << EOF
<!--BEGIN FOOTER-->
</div>
</div>
</body>
</html>
<!--END FOOTER-->
EOF
