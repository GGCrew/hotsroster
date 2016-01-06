for erbfile in **/*.erb; do
#	echo "$erbfile"
	dir=$(dirname "$erbfile")
	base=$(basename "$erbfile" .erb)
	hamlfile="$dir/$base.haml"
#	echo "$hamlfile"
	git mv "$erbfile" "$hamlfile"
done

