#!/bin/bash


WORKDIR=$1

FILES=`find "$WORKDIR" -name '*.html' | grep -v html-out.html`


for f in $FILES
do
	xsltproc --html  wiki-clean.xslt $f > $f-out.html
done

