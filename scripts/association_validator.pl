#!/usr/bin/perl

use strict;
use warnings;

#  Use Chris Mungall's GO::Parser to do the searching for is_obsoletes
use GO::Parser;

# module to download remote ontology files
use File::Fetch;


# check for arguments and explain usage
if ($#ARGV !=0) {
	print "usage: association_validator.pl assoc_directory\n";
	exit;
}

my $directory = $ARGV[0];

# hash to store obsolete terms
my %obs_terms_hash;

# define external ontology files
my $PECO_filename = "peco.obo";
my $PO_filename = "plant-ontology.obo";
my $GO_filename = "go.obo";
my $TO_filename = "plant-trait-ontology.obo";

my $PECO_file_url = "http://github.com/Planteome/plant-experimental-conditions-ontology/raw/master/$PECO_filename";
my $PO_file_url = "http://github.com/Planteome/plant-ontology/raw/master/$PO_filename";
my $GO_file_url = "http://purl.obolibrary.org/obo/$GO_filename";
my $TO_file_url = "http://github.com/Planteome/plant-trait-ontology/raw/master/$TO_filename";

my %ont_files_hash;

$ont_files_hash{'PECO_file'}->{'filename'} = $PECO_filename;
$ont_files_hash{'PECO_file'}->{'url'} = $PECO_file_url;
$ont_files_hash{'PO_file'}->{'filename'} = $PO_filename;
$ont_files_hash{'PO_file'}->{'url'} = $PO_file_url;
$ont_files_hash{'GO_file'}->{'filename'} = $GO_filename;
$ont_files_hash{'GO_file'}->{'url'} = $GO_file_url;
$ont_files_hash{'TO_file'}->{'filename'} = $TO_filename;
$ont_files_hash{'TO_file'}->{'url'} = $TO_file_url;

my $key;
if($directory =~ /go/){
	$key = 'GO_file';
}elsif($directory =~ /peco/) {
		$key = 'PECO_file';
}elsif($directory =~ /po/) {
		$key = 'PO_file';
}elsif($directory =~ /to/){
		$key = 'TO_file';
}else{
		print "ontology undetermined\n";
}


my $obo_file;
# Don't need to redownload if we have in the last day
if(-e "/tmp/$ont_files_hash{$key}->{'filename'}") {
		my $modtime = (stat("/tmp/$ont_files_hash{$key}->{'filename'}"))[9];
		my $currtime = time();
		my $time_since_mod = $currtime - $modtime;
		print "file = $key\tmodtime = $modtime\tcurrtime = $currtime\ttime_since_mod = $time_since_mod\n";
		if($time_since_mod < 86400){
				$obo_file = "/tmp/$ont_files_hash{$key}->{'filename'}";
				print "obo_file = $obo_file\n";
		}else{
				my $ff = File::Fetch->new(uri => $ont_files_hash{$key}->{'url'});
				# fetch the uri to /tmp
				my $where = $ff->fetch( to => '/tmp' ) or die $ff->error;
				$obo_file = $where;
		}
}else{
		my $ff = File::Fetch->new(uri => $ont_files_hash{$key}->{'url'});
		# fetch the uri to /tmp
		my $where = $ff->fetch( to => '/tmp' ) or die $ff->error;
		$obo_file = $where;
}

# init GO parser
my $parser = GO::Parser->new({handler=>'obj'});
$parser->parse($obo_file);

my $ont = $parser->handler->graph;


my $obo_terms = $ont->get_all_nodes;

my %terms_aspect_hash;
my %namespace_aspect_hash = ( 'biological_process' => 'P',
	'molecular_function' => 'F',
	'cellular_component' => 'C',);

foreach my $term (@$obo_terms) {
	my $id = $term->acc;
	my $name = $term->name;
	if ($term->is_obsolete){
		$obs_terms_hash{$id} = $name;
	}
	if ($id =~ m/^GO/) {
		my $aspect = $term->namespace;
		$terms_aspect_hash{$id} = $namespace_aspect_hash{$aspect};
	}
}

my %line_hash;

my $line_number;

my @files = glob("$directory/*.assoc");

foreach my $infile (@files) {
		open (INFILE, $infile);
		print "working on file $infile\n";
		my $gaf_format = 1;
		$line_number = 0;
		while(<INFILE>) {
				my $line = $_;
				chomp $line;
				
				
				$line_number++;
				
				if (/\x0D\x0A/) {
					print "$infile\tAssociation file is in DOS format, please fix by running dos2unix\n";
					next;
				}
				
				
				#my ($db,$db_id,$db_symbol,$qual,$ont_id,$db_ref,$ev,$with,$aspect,$db_obj_name,$db_obj_syn,$db_obj_type,$taxon,$date,$assigned_by,$annot_ext,$gp_form_id) = split("\t", $line);
				my @col_array = split("\t", $line, -1);
				
				# detect empty lines
				if(!$col_array[0]) {
						print "$infile:\tempty line on line $line_number\n";
						next;
				}
				
				#determine gaf version
				if($line_number == 1 && $col_array[0] =~ /gaf-version:\s+2/) {
						$gaf_format = "2";
				}
				
				#skip comments
				next if($col_array[0] =~ m/^!/);
				
				
				# deal with each element separately looking for issues
				my $db = $col_array[0];
				if($db eq "" || $db eq "-"){
						print "$infile:\tdb source not defined on line $line_number\n";
				}
				
				my $db_id = $col_array[1];
				if($db_id eq "" || $db_id eq "-"){
						print "$infile:\tdb object id not defined on line $line_number\n";
				}
				
				my $db_symbol = $col_array[2];
				if($db_symbol eq "" || $db_symbol eq "-"){
						print "$infile:\tdb object symbol not defined on line $line_number\n";
				}
				
				my $qual = $col_array[3];
				#optional, so no check if empty
				
				my $ont_id = $col_array[4];
				if($ont_id eq "" || $ont_id eq "-"){
						print "$infile:\tontology term id not defined on line $line_number\n";
				}elsif ($ont_id !~ /:/){
						print "$infile:\tontology term id missing colon on line $line_number\n";
				}elsif (defined($obs_terms_hash{$ont_id})) {
						print "$infile:\tontology term id $ont_id is obsoleted on line $line_number\n";
				}
				
				my $db_ref = $col_array[5];
				if($db_ref eq "" || $db_ref eq "-"){
						print "$infile:\treference not defined on line $line_number\n";
				#}elsif ($db_ref !~ /:/){
				#		print "reference not properly formatted, missing colon on line $line_number\n";
				}elsif ($db_ref =~ /\s/){
						print "$infile:\tspaces are not allowed in reference list on line $line_number. Reference list is $db_ref\n";
				}
				
				my $ev = $col_array[6];
				if($ev eq "" || $ev eq "-"){
						print "$infile:\tevidence code not defined on line $line_number\n";
				}
				
				my $with = $col_array[7];
				if ($with =~ /\s/){
						print "$infile:\tspaces are not allowed in with/from list on line $line_number\n";
				}
				
				my $aspect = $col_array[8];
				if($aspect eq "" || $aspect eq "-"){
						print "$infile:\taspect not defined on line $line_number for term $ont_id\n";
				}elsif (defined($terms_aspect_hash{$ont_id}) && $aspect ne $terms_aspect_hash{$ont_id}) {
						print "$infile:\tincorrect aspect on line $line_number for term $ont_id\n";
				}
				
				my $db_obj_name = $col_array[9];
				#pretty much anything can go here
				
				my $db_obj_syn = $col_array[10];
				#pretty much anything can go here
				
				my $db_obj_type = $col_array[11];
				#we don't want spaces here
				if($db_obj_type =~ /\s/){
						print "$infile:\tobject type has spaces in it on line $line_number\n";
				}
				
				my $taxon = $col_array[12];
				if($taxon !~ /taxon:/i ){
						print "$infile:\ttaxon column is missing taxon prefix on line $line_number\n";
				}
				
				my $date = $col_array[13];
				if($date !~ /^\d{8}$/ || $date !~ /^20/){
						print "$infile:\tdate column is not properly formatted (YYYYMMDD) on line $line_number\n";
				}
				
				my $assigned_by = $col_array[14];
				#Can't be empty if only gaf 1.0 format
				if(!defined($assigned_by) && $gaf_format ne "2") {
						print "$infile:\tthis appears to be gaf 1.0 format and assigned by column is empty on line $line_number\n";
				}
		
				
				if($gaf_format eq "2") {
						# must have 17 columns
						my $num_columns = @col_array;
						if ($num_columns != 17) {
								print "$infile:\tthere must be exactly 17 columns on line $line_number. There are $num_columns\n";
								next;
						}
						
						my $annot_ext = $col_array[15];
						#spaces not allowed
						if ($annot_ext =~ /\s/) {
								print "$infile:\tspaces are not allowed in annotation extension column on line $line_number\n";
						}
						
						my $gp_form_id = $col_array[16];
						#needs have a colon
						if ($gp_form_id !~ /^$/ && $gp_form_id !~ /:/) {
								print "$infile:\tgene product form id (column 17) needs to have a colon if not empty on line $line_number\n";
						}

						
				}
				
		}			
		close(INFILE);		
		
}


