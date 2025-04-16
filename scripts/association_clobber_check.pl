#!/usr/bin/perl

use strict;
use warnings;

use Tie::Hash::Regex;

# check for arguments and explain usage
if ($#ARGV !=0) {
	print "usage: associations_clobber_check.pl directory\n";
	exit;
}

my $directory = $ARGV[0];

my @files = glob("$directory/*associations/*.assoc");

# hash to store entries, key is db+gene, value is file
my %gene_hash;
my $count =0;

foreach my $infile (@files){
	open (INFILE, $infile);
	while(<INFILE>) {
		my $line = $_;
		chomp $line;
	
		$infile =~ s|\.\/\/||g;
		
		my ($db,$db_id,$db_symbol,$qual,$ont_id,$db_ref,$ev,$with,$aspect,$db_obj_name,$db_obj_syn,$db_obj_type,$taxon,$date,$assigned_by,$annot_ext,$gp_form_id) = split("\t", $line);
		if($db =~ m/^!/ || $db =~ m/^$/) {
			next;
		}else{
			my $gene_key = "$db:$db_id"; #key for gene_hash
			if(defined($gene_hash{$gene_key})) {
				if($gene_hash{$gene_key}->{'file'} =~ m/$infile/) {
					$gene_hash{$gene_key}->{'line'} = "$gene_hash{$gene_key}->{'line'}\n$line";
					next;
				}else{
					$gene_hash{$gene_key}->{'file'} = "$gene_hash{$gene_key}->{'file'}\t$infile";
					$gene_hash{$gene_key}->{'line'} = "$gene_hash{$gene_key}->{'line'}\n$line";
					#print "$gene_hash{$gene_key}\n";
					#print OUTFILE "$gene_key\t$gene_hash{$gene_key}\n";
					#print OUTFILE "$line\n";
					$count++;
				}
			}else{
				$gene_hash{$gene_key}->{'file'} = "$infile";
				$gene_hash{$gene_key}->{'line'} = "$line";
			}
		}
												
	}
	close (INFILE);
}



print "count = $count\n";

my %file_hash;
tie %file_hash, 'Tie::Hash::Regex';

open (OUTFILE, ">gene_clobber_list.txt");
print OUTFILE "!gaf-version: 2.0\n";

foreach my $key (keys %gene_hash){
	if($gene_hash{$key}->{'file'} =~ m/\t/) {
		$file_hash{$gene_hash{$key}->{'file'}} = 1;
		my @line_array = split("\n", $gene_hash{$key}->{'line'});
		foreach my $line (@line_array) {
			if($line !~ m/^$/) {print OUTFILE "$line\n";}
		}
		if(exists($file_hash{'$key\t'})) {
			$file_hash{$gene_hash{$key}->{'file'}} = 0;
		}

	}
}
close(OUTFILE);

foreach my $key (keys %file_hash){
	if($file_hash{$key} eq 1){
		print "$key\n";
	}
}
