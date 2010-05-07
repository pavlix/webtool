actions="configure make install sync"
for a in $actions; do
    sh $webtooldir/commands/$a.sh || exit 1
done
