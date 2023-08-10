#!/usr/bin/perl

use strict;
use warnings;

# Include module for number formatting
use Number::Format 'format_number';

# check for arguments and explain usage
if ($#ARGV !=2) {
	print "usage: annot_by_taxa_release_notes.pl old_tsv_file new_tsv_file out_file\n";
	exit;
}

my $old_tsv_file = $ARGV[0];
my $new_tsv_file = $ARGV[1];
my $out_file = $ARGV[2];

# Read in old tsv file to get taxon ids and common names
# Can just be copy/pasted from old release notes on drupal page
my %old_hash;
open(OLDTSVFILE, "$old_tsv_file");
while(<OLDTSVFILE>) {
    my $line = $_;
    chomp $line;
    my ($name, $taxon, $common_name, $count) = split("\t", $line);
    $old_hash{$name}->{'taxon'} = $taxon;
    $old_hash{$name}->{'common_name'} = $common_name;
}
close(OLDTSVFILE);

# Read in the new file file and merge the data in to the output file
open(NEWTSVFILE, "$new_tsv_file");
open(OUTFILE, ">$out_file");
while(<NEWTSVFILE>) {
    my $line = $_;
    chomp $line;
    my ($name, $count) = split("\t", $line);
    my $formatted_count = format_number($count);
    if(defined($old_hash{$name})) {
        my $taxon_string = '<a href="https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&amp;id=' . $old_hash{$name}->{'taxon'} . '">' . $old_hash{$name}->{'taxon'} . '</a>';
        print OUTFILE "<tr><td>$name</td><td>$taxon_string</td><td>$old_hash{$name}->{'common_name'}</td><td>$formatted_count</td></tr>\n";
    }else{
        print OUTFILE "<tr><td>$name</td><td></td><td></td><td>$formatted_count</td></tr>\n";
    }
}
close(NEWTSVFILE);
close(OUTFILE);