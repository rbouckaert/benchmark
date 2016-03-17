@d = ("M1044	50	1133   493","M1366	41	1137   769","M1510	36	1812   1020","M1748	67	955    336","M1749	74	2253   1673","M1809	59	1824   1037","M336	27	1949    934","M3475	50	378    256","M501	29	2520    1253","M520	67	1098    534","M755	64	1008    407","M767	71	1082    446", "benchmark1 1441 987 593", "benchmark2 62 10869 5565", "old_benchmark 17 1485 138");

process("singleThread");
showResult();

process("doubleThread");
showResult();

process("fourThread");
showResult();

process("GPU");
showResult();

sub process {
    $dir = shift;
    undef(@beast1);
    undef(@beast2);
    open(FIN,"grep user $dir/times1.dat|");
    for ($j = 0; $j < 4; $j++) {
        for ($i = 0; $i < 12; $i++) {
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
        for ($i = 0; $i < 12; $i++) {
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
    for ($i = 0; $i < 12; $i++) {
        print "M$d[$i]\t";
        for ($j = 3; $j >= 0; $j--) {
            print "$beast1[$j][$i]\t$beast2[$j][$i]\t";
        }
        print "\n";
    }
    print "\n";
}
