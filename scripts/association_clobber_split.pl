#!/usr/bin/perl

use strict;
use warnings;

use Tie::Hash::Regex;

# check for arguments and explain usage
if ($#ARGV !=1) {
	print "usage: associations_clobber_split.pl input_file output_file_prefix\n";
	exit;
}

my $in_file = $ARGV[0];
my $out_file_prefix = $ARGV[1];

my $line_size = 500000;
my $file_counter = 1;
my $line_counter = 1;

my $prev_gene_key = "";
my $gene_key = "temp";

my $out_file = sprintf("$out_file_prefix.%02d", $file_counter);

open(OUTFILE, ">$out_file");
print OUTFILE "!gaf-version: 2.0\n";

open (INFILE, $in_file);
while(<INFILE>) {
	my $line = $_;
	chomp $line;	
	my ($db,$db_id,$db_symbol,$qual,$ont_id,$db_ref,$ev,$with,$aspect,$db_obj_name,$db_obj_syn,$db_obj_type,$taxon,$date,$assigned_by,$annot_ext,$gp_form_id) = split("\t", $line);
	if($db =~ m/^!/ || $db =~ m/^$/) {
		next;
	}else{
		$gene_key = "$db:$db_id"; #key for gene_hash
	}

	#print "gene_key = $gene_key\tprev_gene_key = $prev_gene_key\n";
	if($line_counter > $line_size && $gene_key ne $prev_gene_key) {
	#if($gene_key ne $prev_gene_key) {
	#if($line_counter > $line_size) {
		$file_counter++;
		my $out_file = sprintf("$out_file_prefix.%02d", $file_counter);
		open(OUTFILE, ">$out_file");
		print OUTFILE "!gaf-version: 2.0\n";
		print OUTFILE "$line\n";
		$line_size += 500000;
	}else{
		print OUTFILE "$line\n";
	}
	$prev_gene_key = $gene_key;
	$line_counter++;
}
close(INFILE);


