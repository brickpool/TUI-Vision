package TUI::FormBuilder::Object;

use strict;
use warnings;
use Scalar::Util qw(weaken);

use TUI::FormBuilder::Property;

sub new {
  my ( $class, %args ) = @_;

  die 'context is required' unless defined $args{context};
  die 'node is required'    unless ref( $args{node} ) eq 'HASH';

  my $node = $args{node};

  die 'AST node type is required'
    unless defined $node->{type};

  die 'AST node name is required'
    unless defined $node->{name};

  my $self = bless {
    context    => $args{context},
    parent     => $args{parent},
    node       => $node,
    properties => undef,
    children   => undef,
    target     => undef,
  }, $class;

  weaken( $self->{context} );
  weaken( $self->{parent} ) if $self->{parent};

  return $self;
} #/ sub new

sub context {
  return $_[0]->{context};
}

sub parent {
  return $_[0]->{parent};
}

sub type {
  return $_[0]->{node}{type};
}

sub name {
  return $_[0]->{node}{name};
}

sub properties {
  my $self = shift;

  return values %{ $self->{properties} }
    if $self->{properties};

  my %properties;

  for my $name ( keys %{ $self->{node}{properties} // {} } ) {
    $properties{$name} = TUI::FormBuilder::Property->new(
      name  => $name,
      value => $self->{node}{properties}{$name},
      owner => $self,
    );
  }

  $self->{properties} = \%properties;

  return values %properties;
} #/ sub properties

sub has_property {
  my ( $self, $name ) = @_;

  $self->properties unless $self->{properties};

  return exists $self->{properties}{$name};
}

sub property {
  my ( $self, $name ) = @_;

  $self->properties unless $self->{properties};

  return $self->{properties}{$name};
}

sub take {
  my ( $self, $name, $default ) = @_;

  my $property = $self->property( $name );

  return $default unless $property;

  return $property->consume;
}

sub children {
  my $self = shift;

  return @{ $self->{children} } if $self->{children};

  my @children = map {
    TUI::FormBuilder::Object->new(
      context => $self->{context},
      parent  => $self,
      node    => $_,
    )
  } @{ $self->{node}{children} // [] };

  $self->{children} = \@children;

  return @children;
}

sub build {
  my $self = shift;

  return $self->{target} if $self->{target};

  my $context = $self->{context}
    or die 'Build context is no longer available';

  $self->{target} = $context->build( $self );

  return $self->{target};
}

sub unconsumed_properties {
  my $self = shift;

  return grep { !$_->consumed } $self->properties;
}

1
