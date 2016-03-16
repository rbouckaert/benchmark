# benchmark

BEAST benchmarking data

run "perl process.pl" to generate XML files in the "generated" directory

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

Timing information will be displayed on the console.
