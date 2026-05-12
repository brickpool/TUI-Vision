package TUI::Validate::Validator;
# ABSTRACT: Abstract base class for validators

use 5.010;
use strict;
use warnings;

our $VERSION = '2.000001';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Exporter 'import';
our @EXPORT = qw(
  TValidator
  new_TValidator
);

use TUI::toolkit;
use TUI::toolkit::Types qw( :types );

use TUI::Objects::Object;

sub TValidator() { __PACKAGE__ }
sub name() { 'TValidator' };
sub new_TValidator { __PACKAGE__->from(@_) }

extends TObject;

# public attributes
has status  => ( is => 'rw', default => 0 );
has options => ( is => 'rw', default => 0 );

sub error {    # void ()
  state $sig = signature(
    method => Object,
    pos    => [],
  );
  $sig->( @_ );
  return;
}

sub isValidInput {    # $bool ($s, $suppressFill)
  state $sig = signature(
    method => Object,
    pos    => [Str, Bool],
  );
  $sig->( @_ );
  return true;
}

sub isValid {    # $bool ($s)
  state $sig = signature(
    method => Object,
    pos    => [Str],
  );
  $sig->( @_ );
  return true;
}

sub transfer {    # $value ($s, $buffer, $flags)
  state $sig = signature(
    method => Object,
    pos    => [Str, Any, PositiveOrZeroInt],
  );
  $sig->( @_ );
  return 0;
}

sub validate {    # $bool ($s)
  state $sig = signature(
    method => Object,
    pos    => [Str],
  );
  my ( $self, $s ) = $sig->( @_ );
  if ( !$self->isValid( $s ) ) {
    $self->error();
    return false;
  }
  return true;
}

1
