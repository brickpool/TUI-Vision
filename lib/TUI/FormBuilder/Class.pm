package TUI::FormBuilder::Class;

use strict;
use warnings;

sub new {
  my ( $class, %args ) = @_;

  die 'source_type is required'
    unless defined $args{source_type};

  die 'target_class is required'
    unless defined $args{target_class};

  return bless {
    source_type  => $args{source_type},
    source_name  => $args{source_name},
    target_class => $args{target_class},
    match        => $args{match},
  }, $class;
}

sub source_type {
  return $_[0]->{source_type};
}

sub source_name {
  return $_[0]->{source_name};
}

sub target_class {
  return $_[0]->{target_class};
}

sub matches {
  my ( $self, $object ) = @_;

  return 0 unless $object->type eq $self->{source_type};

  return 0
    if defined $self->{source_name}
    && $object->name ne $self->{source_name};

  return 0
    if $self->{match}
    && !$self->{match}->( $object );

  return 1;
}

1;
