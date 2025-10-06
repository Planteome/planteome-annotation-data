#!/usr/bin/perl

use strict;
use warnings;

# check for arguments and explain usage
if ($#ARGV !=2) {
	print "usage: association_aspect_fixer.pl go_id_file in_file out_file\n";
	exit;
}

my $go_id_file = $ARGV[0];
my $infile = $ARGV[1];
my $outfile = $ARGV[2];

my %go_hash;

open (GOFILE, $go_id_file);
while(<GOFILE>) {
		my $line = $_;
		chomp $line;
		
		my ($go_id,$go_aspect) = split("\t", $line);
		next if ($go_aspect eq "");
		if(defined($go_hash{$go_id})){
				print "multiple aspects found for $go_id\n";
				die;
		}else{
				$go_hash{$go_id}= $go_aspect;
		}
}
close(GOFILE);


open (INFILE, $infile);
open (OUTFILE, ">$outfile");
my $counter=0;
while(<INFILE>) {
		my $line = $_;
		chomp $line;
		$counter++;
		
		my ($db,$db_id,$db_symbol,$qual,$ont_id,$db_ref,$ev,$with,$aspect,$db_obj_name,$db_obj_syn,$db_obj_type,$taxon,$date,$assigned_by,$annot_ext,$gp_form_id) = split("\t", $line);
		if($db =~ m/^!/) {
				print OUTFILE "$line\n";
				next;
		}
		
		if(defined($go_hash{$ont_id})){
				if($aspect eq $go_hash{$ont_id}) {
						print OUTFILE "$line\n";
				}else{
						print OUTFILE "$db\t$db_id\t$db_symbol\t$qual\t$ont_id\t$db_ref\t$ev\t$with\t$go_hash{$ont_id}\t$db_obj_name\t$db_obj_syn\t$db_obj_type\t$taxon\t$date\t$assigned_by\t$annot_ext\t$gp_form_id\n";
				}
		}else{
			#	print "ID not found on line $counter for $ont_id\n";
				print OUTFILE "$line\n";
		}
		


}
close (INFILE);
close (OUTFILE);

