#!/bin/bash

make_html()
{
  pandoc -f markdown  -t html $1.md > $1.html
}

mkdir -p html
document_directory=Documentation
for doc in  $document_directory/*.md;
do
  base=`basename $doc .md`
  document=$document_directory/$base
  make_html  $document
  mv "$document.html" html/
done
