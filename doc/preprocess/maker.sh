#!/bin/bash
mkdir -p templates/concurrency_view/sub
mkdir -p templates/skeletons/sub
mkdir -p output

cat  $1 | awk -f f.awk 
find . -type f -iname '*tmplt' | \
    cut -c 3- | \
    while read ANS ; do \
        mv -i "$ANS" output/"$(echo ${ANS/.tmplt/} | sed 's,[/-],_,g')" ; \
    done
find . -type f -iname '*.pre' | \
    cut -c 3- | \
    while read ANS ; do \
        cat "$ANS" | sed 1d > output/"$(echo ${ANS/.tmplt.pre/.pre} | sed 's,[/-],_,g')"
    done
find . -type f -iname '*.post' | \
    cut -c 3- | \
    while read ANS ; do \
        cat "$ANS" | sed 1d > output/"$(echo ${ANS/.tmplt.post/.post} | sed 's,[/-],_,g')"
    done
rm -rf templates
