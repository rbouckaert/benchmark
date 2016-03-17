#!/usr/bin/env perl

@d = ("1044	50	1133   493","1366	41	1137   769","1510	36	1812   1020","1748	67	955    336","1749	74	2253   1673","1809	59	1824   1037","336	27	1949    934","3475	50	378    256","501	29	2520    1253","520	67	1098    534","755	64	1008    407","767	71	1082    446", "bench1	1441	987	593", "bench2	62	10869	5565", "old	17	1485	138");

@m = ("GTR.G.I", "GTR.G", "GTR.I", "GTR");

open(FOUT, ">data_frame.txt");
print FOUT "version run dataset taxa sites patterns model time\n";

process("singleThread");
showResult();

process("doubleThread");
showResult();

process("fourThread");
showResult();

process("GPU");
showResult();

close FOUT;

sub process {
    $dir = shift;
    undef(@beast1);
    undef(@beast2);
    open(FIN,"grep user $dir/times1.dat|");
    for ($j = 0; $j < 4; $j++) {
        for ($i = 0; $i < 15; $i++) {
            $s = <FIN>;
            @s = split(" ",$s);
            $s = $s[2];
            $s =~ s/elapsed//;
            @s = split(":",$s);
            $beast1[$j][$i] = 60.0*$s[0] + $s[1];
        }
    }
    close FIN;

    open(FIN,"grep user $dir/times2.dat|");
    for ($j = 0; $j < 4; $j++) {
        for ($i = 0; $i < 15; $i++) {
            $s = <FIN>;
            @s = split(" ",$s);
            $s = $s[2];
            $s =~ s/elapsed//;
            @s = split(":",$s);
            $beast2[$j][$i] = 60.0*$s[0] + $s[1];
        }
    }
    close FIN;
}


sub showResult {
    print "\n\n$dir\n";
    print "dataset taxa sites patterns GTR . GTR+I . GTR+G . GTR+G+I\n";
    print ". . . . BEAST1 BEAST2 BEAST1 BEAST2 BEAST1 BEAST2 BEAST1 BEAST2\n";
    for ($i = 0; $i < 15; $i++) {
        print "$d[$i]\t";
        for ($j = 3; $j >= 0; $j--) {
            print "$beast1[$j][$i]\t$beast2[$j][$i]\t";
            print FOUT "BEAST1\t$dir\t$d[$i]\t$m[$j]\t$beast1[$j][$i]\n";
            print FOUT "BEAST2\t$dir\t$d[$i]\t$m[$j]\t$beast2[$j][$i]\n";
        }
        print "\n";

    }
    print "\n";
}
