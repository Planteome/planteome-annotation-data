#!/usr/bin/perl

use strict;
use warnings;

#  Use Chris Mungall's GO::Parser to do the searching for is_obsoletes
use GO::Parser;

# module to download remote ontology files
use File::Fetch;

open(OUTFILE, ">go_aspects.txt");

# define external ontology files
my $GO_filename = "go.obo";

my $GO_file_url = "http://purl.obolibrary.org/obo/$GO_filename";

my $obo_file = "/tmp/$GO_filename";


# Don't need to redownload if we have in the last day
if(-e "/tmp/$GO_filename") {
	my $modtime = (stat("/tmp/$GO_filename"))[9];
	my $currtime = time();
	my $time_since_mod = $currtime - $modtime;
	if($time_since_mod < 86400){
		$obo_file = "/tmp/$GO_filename";
		print "obo_file = $obo_file\n";
	}else{
		my $ff = File::Fetch->new(uri => $GO_file_url);
		# fetch the uri to /tmp
		my $where = $ff->fetch( to => '/tmp' ) or die $ff->error;
		$obo_file = $where;
	}
}else{
	my $ff = File::Fetch->new(uri => $GO_file_url);
	# fetch the uri to /tmp
	my $where = $ff->fetch( to => '/tmp' ) or die $ff->error;
	$obo_file = $where;
}

# init GO parser
my $parser = GO::Parser->new({handler=>'obj'});
$parser->parse($obo_file);

my $ont = $parser->handler->graph;


my $obo_terms = $ont->get_all_nodes;

my %namespace_aspect_hash = ( 'biological_process' => 'P',
	'molecular_function' => 'F',
	'cellular_component' => 'C',);

foreach my $term (@$obo_terms) {
	my $id = $term->acc;
	my $name = $term->name;
	my $aspect = $namespace_aspect_hash{$term->namespace};
	print OUTFILE "$id\t$aspect\n";
}
