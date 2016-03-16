# benchmark
BEAST benchmarking data

run "perl process.pl" to generate XML files in the "generated" directory

It also produces a script /generated/_experiment.sh which assumes that 
there are two scripts for running BEAST 1 & 2 in the folder above generated.
These are called 

../beast1 for running BEAST1 XML and could contain something like

export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/cuda/lib64:/usr/local/cuda/lib64:/usr/local/cuda/lib

java -Djava.library.path=/usr/local/lib -jar /home/remco/data/beast/benchmark/beast1.8.3.jar $*

../beast2 for runnign BEAST2 XML

export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/cuda/lib64:/usr/local/cuda/lib64:/usr/local/cuda/lib

java -Djava.library.path=/usr/local/lib -jar /home/remco/data/beast/benchmark/beast2.4.0.jar $*

assuming beast1.8.3.jar and beast2.4.0.jar are in the main folder (change 
the path to what is appropriate for your computer).

run "chmod 777 ./generated/_experiment.sh" to make the script executable.  

Time will print out to console instead of the large log file.

