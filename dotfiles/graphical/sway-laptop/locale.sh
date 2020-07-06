#!/usr/bin/env bash
engine=$(ibus engine)
if [ "${engine}" == "mozc-jp" ] || [ "${engine}" == "xkb:jp::jpn" ]
then
    ibus engine xkb:us::eng
else
    ibus engine mozc-jp
fi
