#!/bin/sh

folders=( "singleThread" "doubleThread" "fourThread" "GPU" )
for f in "${folders[@]}"; do
  cd $f
  sed -i.bak '/.*Fail.*/d;/.*line.*/d;/.*ile.*/d;/.*WARN.*/d;/.*Igno.*/d;/.*With.*/d;/.*Using.*/d;/.*End.*/d;/^\s*$/d;' time.txt
  echo "clean time.txt in" $f
  cd ..
done
