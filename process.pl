
`mkdir generated`;
$chainLength="1000000";

foreach $f (glob("data/*.nex")) {
	$n = 0;
	print STDERR "Processing $f\n";
	open(FIN, $f) or die "cannot open $f";
	while (($s = <FIN>) && ($s !~ /matrix/)) {}
	while (($s = <FIN>) && ($s !~ /^\s*$/)) {
		@s = split('\s+', $s);
		if ($#s != 2) {
			print STDERR "Expected two words, not $#s $s[1]\n";
		}
		$taxon[$n] = $s[1];
		$seq[$n] = $s[2];
		$n++;
	}
	
	$f =~ s/data\///;
	$f =~ s/testHKY(.*).nex/$1/;
	generate1();
	generate2();
	close FIN;
}


open(FOUT,">generated/_experiment.sh");
print FOUT "#!/bin/bash\n";
print FOUT "mkdir singleThread\n";
print FOUT "cd singleThread\n";
print FOUT "mkdir test_xml\n";
doWith(1);
print FOUT "cd ..\n";

print FOUT "mkdir doubleThread\n";
print FOUT "cd doubleThread\n";
print FOUT "mkdir test_xml\n";
doWith(2);
print FOUT "cd ..\n";

print FOUT "mkdir fourThread\n";
print FOUT "cd fourThread\n";
print FOUT "mkdir test_xml\n";
doWith(4);
print FOUT "cd ..\n";

print FOUT "mkdir GPU\n";
print FOUT "cd GPU\n";
print FOUT "mkdir test_xml\n";
doGPU();
print FOUT "cd ..\n";
close FOUT;



sub doWith {
	$threads = shift;
	print FOUT "echo \"\" >times1.dat\n";
	print FOUT "echo \"\" >times2.dat\n";
	foreach $f (sort(glob("generated/*_1_*.xml"))) {
		print FOUT "echo $f\n";
		print FOUT "/usr/bin/time ../beast1 -overwrite -beagle_instances $threads -threads $threads ../$f >/dev/null 2>> times1.dat\n";
		print FOUT "printf \"\\n\"\n";
		$f =~ s/_1_/_2_/;
		print FOUT "echo $f\n";
		print FOUT "/usr/bin/time ../beast2 -overwrite -instances $threads -threads $threads ../$f >/dev/null 2>> times2.dat\n";
		print FOUT "printf \"\\n\"\n";
	}
}


sub doGPU {
	$threads = shift;
	print FOUT "echo \"\" >times1.dat\n";
	foreach $f (sort(glob("generated/*_1_*.xml"))) {
		print FOUT "echo $f\n";
		print FOUT "/usr/bin/time ../beast1 -overwrite -beagle_GPU -beagle_order 1 ../$f >/dev/null 2>> times1.dat\n";
		print FOUT "printf \"\\n\"\n";
		$f =~ s/_1_/_2_/;
		print FOUT "echo $f\n";
		print FOUT "/usr/bin/time ../beast2 -overwrite -beagle_GPU ../$f >/dev/null 2>> times2.dat\n";
		print FOUT "printf \"\\n\"\n";
	}
}

sub generate1 {
	merge1("xml/GTR_1.xml");
	merge1("xml/GTRI_1.xml");
	merge1("xml/GTRG_1.xml");
	merge1("xml/GTRGI_1.xml");
}

sub merge1 {
	$src = shift;
	$type_ = $src;
	$type_ =~ s/.xml/_/;
	$target = $src;
	$target =~ s/xml\///;
	$target =~ s/.xml/_$f.xml/;
	open (FIN, $src) or die "cannot open file $src" or die "cannot read $src";
	open (FOUT, ">generated/_$target") or die "Cannot write generated/_$target" ;

	$taxa = '';
	$seqs = '';
	for ($i = 0; $i < $n; $i++) {
		$taxa .= "<taxon id=\"$taxon[$i]\"/>\n";
		$seqs .= "<sequence>\n<taxon idref=\"$taxon[$i]\"/>\n$seq[$i]\n</sequence>\n";
	}
	while ($s = <FIN>) {
		$s =~ s/fileName="test/fileName="test_$type_$f/;
		$s =~ s/#taxa#/$taxa/;
		$s =~ s/#seqs"/$seqs/;
		$s =~ s/chainLength="1000000"/chainLength="$chainLength"/;
		print FOUT $s;
	}
	close FOUT;
	close FIN;
}

sub generate2 {
	merge2("xml/GTR_2.xml");
	merge2("xml/GTRI_2.xml");
	merge2("xml/GTRG_2.xml");
	merge2("xml/GTRGI_2.xml");

}

sub merge2 {
	$src = shift;
	$type_ = $src;
	$type_ =~ s/.xml/_/;
	$target = $src;
	$target =~ s/.xml/_$f.xml/;
	$target =~ s/xml\///;
	open (FIN, $src) or die "cannot open file $src";
	open (FOUT, ">generated/_$target");
	$s = <FIN>;
	print FOUT $s;
	print FOUT "    <data id=\"test\" name=\"alignment\"\n";
	for ($i = 0; $i < $n; $i++) {
		print FOUT "    $taxon[$i]=\"$seq[$i]\"\n";
	}
	print FOUT "/>\n";
	while ($s = <FIN>) {
		$s =~ s/fileName="test/fileName="test_$type_$f/;
		$s =~ s/fileName="tree/fileName="test_$type_$f/;
		$s =~ s/chainLength="1000000"/chainLength="$chainLength"/;
		print FOUT $s;
	}
	close FOUT;
	close FIN;
}
