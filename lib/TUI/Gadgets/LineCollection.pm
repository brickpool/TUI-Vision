package TUI::Gadgets::LineCollection;
# ABSTRACT: Implement a line collection for the framework.

use 5.010;
use strict;
use warnings;

our $VERSION = '2.000001';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Exporter 'import';
our @EXPORT = qw(
  TLineCollection
  new_TLineCollection
);

use TUI::toolkit;
use TUI::toolkit::Types qw( :types );

use TUI::Objects::Collection;

sub TLineCollection() { __PACKAGE__ }
sub new_TLineCollection { __PACKAGE__->from(@_) }

extends TCollection;

sub BUILDARGS {    # \%args (%args)
  state $sig = signature(
    method => 1,
    named => [
      limit => Int, { alias => 'lim' },
      delta => Int,
    ],
    caller_level => +1,
  );
  my ( $class, $args ) = $sig->( @_ );
  return { %$args };
}

sub from {    # $obj ($lim, $delta)
  state $sig = signature(
    method => 1,
    pos => [Int, Int],
  );
  my ( $class, @args ) = $sig->( @_ );
  return $class->new( limit => $args[0], delta => $args[1] );
}

1
