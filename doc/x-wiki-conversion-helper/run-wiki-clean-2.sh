#!/bin/bash

XSLT=$1
WORKDIR=$2

FILES=`find "$WORKDIR" -name '*.html' | grep -v html-out.html`

## This script will prefix the file with the the typical <html><body> tags
## and also add the matching ending tags at the end of the file. This
## will hide tha YAML header in the HTML, thus making the file a proper HTML
## file, which is then processed with the XSLT stylesheet. Then the added
## tags are removed again, so that the YAML header is again visible to the YAML
## processor.


for f in $FILES
do
	echo "<html><body>" >> $f-tmp.html
	cat $f >> $f-tmp.html
	echo "</body></html>" >> $f-tmp.html
	xsltproc --encoding utf8 --html  "$XSLT" $f-tmp.html > $f-out.html
	tail -n +3 $f-out.html | head -n -1 > $f-tmp.html
	mv $f-tmp.html $f-out.html
	cp $f $f.bak
	mv $f-out.html $f
done

