# RDF::Query::Error
# -------------
# $Revision: 127 $
# $Date: 2006-02-08 14:53:21 -0500 (Wed, 08 Feb 2006) $
# -----------------------------------------------------------------------------

=head1 NAME

RDF::Query::Error - Error classes for RDF::Query.

=head1 VERSION

This document describes RDF::Query::Error version 1.001

=head1 SYNOPSIS

 use RDF::Query::Error qw(:try);

=head1 DESCRIPTION

RDF::Query::Error provides an class hierarchy of errors that other RDF::Query
classes may throw using the L<Error|Error> API. See L<Error> for more information.

=head1 REQUIRES

L<Error|Error>

=cut

package RDF::Query::Error;

use strict;
use warnings;
no warnings 'redefine';
use Carp qw(carp croak confess);

use base qw(Error);

######################################################################

our ($REVISION, $VERSION, $debug);
BEGIN {
	$debug		= 0;
	$REVISION	= do { my $REV = (qw$Revision: 127 $)[1]; sprintf("%0.3f", 1 + ($REV/1000)) };
	$VERSION	= '2.000';
}

######################################################################

package RDF::Query::Error::ParseError;

use base qw(RDF::Query::Error);

package RDF::Query::Error::MethodInvocationError;

use base qw(RDF::Query::Error);

package RDF::Query::Error::MethodError;

use base qw(RDF::Query::Error);

package RDF::Query::Error::ModelError;

use base qw(RDF::Query::Error);

package RDF::Query::Error::QuerySyntaxError;

use base qw(RDF::Query::Error);

package RDF::Query::Error::QueryPatternError;

use base qw(RDF::Query::Error::QuerySyntaxError);

package RDF::Query::Error::SimpleQueryPatternError;

use base qw(RDF::Query::Error::QueryPatternError);

package RDF::Query::Error::CompilationError;

use base qw(RDF::Query::Error);

package RDF::Query::Error::ComparisonError;

use base qw(RDF::Query::Error::CompilationError);

package RDF::Query::Error::SerializationError;

use base qw(RDF::Query::Error);

package RDF::Query::Error::FilterEvaluationError;

use base qw(RDF::Query::Error);

package RDF::Query::Error::TypeError;

use base qw(RDF::Query::Error);

package RDF::Query::Error::ExecutionError;

use base qw(RDF::Query::Error);


1;

__END__

=head1 AUTHOR

 Gregory Williams <gwilliams@cpan.org>

=cut
