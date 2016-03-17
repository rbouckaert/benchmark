#!/bin/sh

for f in {"singleThread", "doubleThread", "fourThread", "GPU"}; do
  cd $f
  sed -i.bak '/.*Fail.*/d;/.*line.*/d;/.*ile.*/d;/.*WARN.*/d;/.*Igno.*/d;/.*With.*/d;/.*Using.*/d;/.*End.*/d;/^\s*$/d' time.txt
  cd ..
done
