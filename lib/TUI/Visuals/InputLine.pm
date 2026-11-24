package TUI::Visuals::InputLine;
# ABSTRACT: Input line with an associated label

use 5.010;
use strict;
use warnings;

our $VERSION = '2.000003';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Exporter 'import';
our @EXPORT = qw(
  VInputLine
  new_VInputLine
);

use Storable;
use TUI::toolkit;
use TUI::toolkit::Types qw(
  :is
  :types
);

use TUI::Dialogs::InputLine;
use TUI::Dialogs::Label;
use TUI::Drivers::Const qw(
  evKeyDown
  evNothing
);
use TUI::Objects::Rect;
use TUI::Views::Const qw(
  focusedEvents
  :ofXXXX
  phPreProcess
  sfDisabled
);
use TUI::Views::Group;

sub VInputLine() { __PACKAGE__ }
sub name() { 'VInputLine' }
sub new_VInputLine { __PACKAGE__->from(@_) }

extends TGroup;

has inputLine => ( is => 'rw' );
has label     => ( is => 'rw' );

sub BUILDARGS {    # \%args (%args)
  state $sig = signature(
    method => 1,
    named  => [
      bounds => Object,
      maxLen => Int, { alias => 'aMaxLen' },
      label  => Str, { alias => 'aLabel' },
    ],
    caller_level => +1,
  );
  my ( $class, $args ) = $sig->( @_ );
  return { %$args };
}

sub BUILD {    # void (\%args)
  my ( $self, $args ) = @_;
  assert ( @_ == 2 );
  assert ( is_Object $self );
  assert ( is_HashRef $args );

  $self->{options} |= ofFirstClick | ofPreProcess;

  my $r = $self->getExtent();
  $r->{a}{y}++;
  $self->{inputLine} = TInputLine->new(
    bounds => $r,
    maxLen => $args->{maxLen},
  );
  $self->insert( $self->{inputLine} );
  $r->move( 0, -1 );
  $self->{label} = TLabel->new(
    bounds => $r,
    text   => $args->{label},
    link   => $self->{inputLine},
  );
  $self->insert( $self->{label} );
  return;
}

sub from {    # $obj ($bounds, $aMaxLen, $aLabel)
  state $sig = signature(
    method => 1,
    pos    => [Object, Int, Str],
  );
  my ( $class, $bounds, $maxLen, $label ) = $sig->( @_ );
  return $class->new( bounds => $bounds, maxLen => $maxLen, label => $label );
}

sub handleEvent {    # void ($event)
  state $sig = signature(
    method => Object,
    pos    => [Object],
  );
  my ( $self, $event ) = $sig->( @_ );

  if ( $self->{owner} && $self->{owner}{phase} == phPreProcess
       && $event->{what} & focusedEvents
    ) {
    if ( $event->{what} == evKeyDown
         && !( $self->{label}{state} & sfDisabled ) 
    ) {
      local $self->{phase} = phPreProcess;
      $self->{label}->handleEvent( $event );
      if ( $event->{what} == evNothing
           && $self->{inputLine}{options} & ofSelectable
      ) {
        # The input may already be selected within an inactive group.
        $self->focus();
      }
    }
    return;
  }

  $self->SUPER::handleEvent( $event );
  return;
}

sub write :method {    # void ($os)
  state $sig = signature(
    method => Object,
    pos    => [Object],
  );
  my ( $self, $os ) = $sig->( @_ );
  $self->SUPER::write( $os );
  $os->put( $self->{inputLine}, $self->{label} );
  return;
}

sub read :method {    # $self ($is)
  state $sig = signature(
    method => Object,
    pos    => [Object],
  );
  my ( $self, $is ) = $sig->( @_ );
  $self->SUPER::read( $is );
  $self->{inputLine} = $is->get();
  $self->{label} = $is->get();
  return $self;
}

sub build {    # $obj ()
  my ( $class ) = @_;
  assert ( @_ == 1 );
  assert ( is_Str $class );
  assert ( Storable::is_retrieving );
  return $class->new( bounds => TRect->new(), maxLen => 0, label => '' );
}

1;
