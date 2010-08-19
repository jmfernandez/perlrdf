#!/usr/bin/perl

use strict;
use warnings;
no warnings 'uninitialized';
use RDF::Trine;
use RDF::Query;
use RDF::Trine::Error qw(:try);
use Scalar::Util qw(blessed);

my @manifests	= glob( "xt/dawg11/*/manifest.ttl" );
my @files	= scalar(@ARGV) ? @ARGV : glob('earl*.ttl');
my $model	= RDF::Trine::Model->temporary_model;
my $parser	= RDF::Trine::Parser->new('turtle');
foreach my $f (@files, @manifests) {
	try {
		$parser->parse_file_into_model( 'file://', $f, $model );
	} catch Error with {
		my $e	= shift;
	};
}

my $query	= RDF::Query->new(<<"END");
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX earl: <http://www.w3.org/ns/earl#>
PREFIX dt: <http://www.w3.org/2001/sw/DataAccess/tests/test-dawg#>
SELECT ?test ?outcome ?approval ?comment
WHERE {
	[] earl:test ?test ; earl:result ?result .
	?result earl:outcome ?outcome .
	OPTIONAL { ?result rdfs:comment ?comment }
	OPTIONAL { ?test dt:approval ?approval }
}
ORDER BY ?test
END

my $iter	= $query->execute( $model );
open( my $git, 'git log|' );
my $rev;
if ($git) {
	my $line;
	do {
		$line	= <$git>;
	} until ($line =~ /^commit (.{7})/);
	if (length($1)) {
		$rev	= "$1";
	}
	close($git);
}

my $date	= scalar(gmtime) . ' GMT';

print <<"END";
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<title>SPARQL 1.1 Evaluation Test Results</title>
<style type="text/css" title="text/css">
/* <![CDATA[ */
			table {
				border: 1px solid #000;
				border-collapse: collapse;
			}
			
			th { background-color: #ddd; }
			td, th {
				padding: 1px 5px 1px 5px;
				border: 1px solid #000;
			}
			
			td.pass { background-color: #0f0; }
			td.fail { background-color: #f00; }
			td.Approved { background-color: #0f0; }
			td.NotClassified { background-color: #ff0; }
/* ]]> */
</style></head>
<body>
<h1>SPARQL 1.1 Test Results for RDF::Query</h1>
<p>As of $date, running with commit $rev (<a href="http://github.com/kasei/perlrdf/tree/dev">HEAD of dev branch at github</a>)</p>

<table>
<tr>
	<th>Test</th>
	<th>Status</th>
	<th>Result</th>
</tr>
END
while (my $row = $iter->next) {
	my ($t, $o, $a)	= map { (blessed($_) and $_->can('uri_value')) ? $_->uri_value : $_ } @{ $row }{ qw(test outcome approval comment) };
	my $c	= $row->{comment};
	if ($c) {
		$c	= $c->literal_value;
	}
	$t	=~ s{http://www.w3.org/2001/sw/DataAccess/tests/data-r2/}{};
	$t	=~ s{http://www.w3.org/2009/sparql/docs/tests/data-sparql11/}{};
	$a	=~ s{http://www.w3.org/2001/sw/DataAccess/tests/test-dawg#}{};
	$o	=~ s{http://www.w3.org/ns/earl#}{};
	print <<"END";
<tr>
	<td>$t</td>
	<td class="$a">$a</td>
	<td class="$o">$o</td>
</tr>
END
}
print <<"END";
</table>
</body>
</html>
END
