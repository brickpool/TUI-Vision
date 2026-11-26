package TUI::FormBuilder::Property;

use strict;
use warnings;
use Scalar::Util qw(weaken);

sub new {
  my ( $class, %args ) = @_;

  die 'name is required'  unless defined $args{name};
  die 'owner is required' unless defined $args{owner};

  my $self = bless {
    name     => $args{name},
    value    => $args{value},
    owner    => $args{owner},
    consumed => 0,
  }, $class;

  weaken( $self->{owner} );

  return $self;
}

sub name {
  return $_[0]->{name};
}

sub value {
  return $_[0]->{value};
}

sub owner {
  return $_[0]->{owner};
}

sub consumed {
  return $_[0]->{consumed};
}

sub consume {
  my $self = shift;

  $self->{consumed} = 1;

  return $self->{value};
}

1
