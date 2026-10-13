#!/bin/bash
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
URL="http://127.0.0.1:8931/Regulating_Conglomerates_%E6%B1%87%E6%8A%A5.html"
OUT="/Users/iris/Desktop/文献阅读/Regulating Conglomerates/.work/ppt-shots"
PROFILE="/Users/iris/Desktop/文献阅读/Regulating Conglomerates/.work/chrome-profile"
mkdir -p "$OUT"
for i in $(seq 1 39); do
  "$CHROME" --headless=new --disable-gpu --no-sandbox --user-data-dir="$PROFILE" \
    --hide-scrollbars --window-size=1600,970 --virtual-time-budget=3000 \
    --screenshot="$OUT/$(printf %02d $i).png" "$URL#$i" >/dev/null 2>&1
done
echo DONE
