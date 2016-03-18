# benchmark

BEAST benchmarking data

run `perl process.pl` to generate XML files in the "generated" directory

It also produces a script `/generated/_experiment.sh`.  This assumes that 
the root directory of this repository contains scripts for running BEAST 1 & 2,
named `beast1` and `beast2` respectively.

Example `beast1` script:

```bash
export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/cuda/lib64:/usr/local/cuda/lib64:/usr/local/cuda/lib
java -Djava.library.path=/usr/local/lib -jar /home/remco/data/beast/benchmark/beast1.8.3.jar $*
```

Example `beast2` script:
```bash
export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/cuda/lib64:/usr/local/cuda/lib64:/usr/local/cuda/lib
java -Djava.library.path=/usr/local/lib -jar /home/remco/data/beast/benchmark/beast2.4.0.jar $*
```

These assume that beast1.8.3.jar and beast2.4.0.jar are in the main folder (change 
the path to what is appropriate for your computer).

Use `chmod a+x ./generated/_experiment.sh` to make the script executable.  

Timing information will be recorded in files times1.dat and times2.dat within each of the
generated directories `singleThread`, `doubleThread`, `fourThread` and `GPU`.

Run the perl script `summarise*.pl` specific to your OS to produce the summary.

If you've run the `summariseLinux.pl` script, a table is produced in `data_frame.txt`
which can be read into R.  This can be visualized using the `plot_summary.R` R script.


For Mac OS, run `perl processMac.pl`. Time will be logged in _time.txt_, and screen logs will be in _screen1.dat_ and _screen2.dat_.

To remove noisy texts from _time.txt_ using the script `cleanTimeLogMac.sh` for all files or the following command for a single file:
```bash
sed -i.bak '/.*Fail.*/d;/.*line.*/d;/.*ile.*/d;/.*WARN.*/d;/.*Igno.*/d;/.*With.*/d;/.*Using.*/d;/.*End.*/d;/^\s*$/d' time.txt
```

Use R script `reportTime.R` to plot figures and print tables.
