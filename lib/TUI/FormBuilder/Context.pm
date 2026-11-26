package TUI::FormBuilder::Context;

use strict;
use warnings;

use TUI::FormBuilder::Parser;
use TUI::FormBuilder::Object;
use TUI::FormBuilder::Class;

sub new {
  my ( $class, %args ) = @_;

  my $self = bless {
    parser   => $args{parser} // TUI::FormBuilder::Parser->new,
    classes  => [],
    root     => undef,
    building => {},
  }, $class;

  $self->register_class( $_ ) for @{ $args{classes} // [] };

  return $self;
}

sub register_class {
  my ( $self, $mapping ) = @_;

  $mapping = TUI::FormBuilder::Class->new( %$mapping )
    if ref( $mapping ) eq 'HASH';

  die 'mapping must be a TUI::FormBuilder::Class'
    unless ref( $mapping )
    && $mapping->isa( 'TUI::FormBuilder::Class' );

  push @{ $self->{classes} }, $mapping;

  return $mapping;
}

sub load_file {
  my ( $self, $filename ) = @_;

  my $ast = $self->{parser}->from_file( $filename );

  $self->{root} = TUI::FormBuilder::Object->new(
    context => $self,
    node    => $ast->{form},
  );

  return $self->{root}->build;
}

sub load_string {
  my ( $self, $source ) = @_;

  my $ast = $self->{parser}->from_string( $source );

  $self->{root} = TUI::FormBuilder::Object->new(
    context => $self,
    node    => $ast->{form},
  );

  return $self->{root}->build;
}

sub class_for {
  my ( $self, $object ) = @_;

  for my $mapping ( @{ $self->{classes} } ) {
    return $mapping if $mapping->matches( $object );
  }

  die sprintf(
    'No target class mapped for %s %s',
    $object->type,
    $object->name,
  );
}

sub build {
  my ( $self, $object ) = @_;

  my $id = "$object";

  die sprintf(
    'Recursive build detected for %s %s',
    $object->type,
    $object->name,
  ) if $self->{building}{$id};

  local $self->{building}{$id} = 1;

  my $mapping = $self->class_for( $object );
  my $target  = $mapping->target_class;

  die "$target does not provide load()"
    unless $target->can( 'load' );

  return $target->load( $object );
} #/ sub build

sub unconsumed_properties {
  my $self = shift;

  my @unconsumed;
  my $walk;

  $walk = sub {
    my ( $object ) = @_;

    push @unconsumed, map {
      {
        object   => $object,
        property => $_,
      }
    } $object->unconsumed_properties;

    $walk->( $_ ) for $object->children;
  };

  $walk->( $self->{root} );

  return @unconsumed;
} #/ sub unconsumed_properties

1;
