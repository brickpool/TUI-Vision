package TUI::Gadgets::ColorDisplay;
# ABSTRACT: color preview view for the color selection dialog

use 5.010;
use strict;
use warnings;

our $VERSION = '2.000001';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Exporter 'import';
our @EXPORT = qw(
  TColorDisplay
  new_TColorDisplay
);

use TUI::toolkit;
use TUI::toolkit::Types qw(
  is_Object
  :types
);

use TUI::Drivers::Const qw( evBroadcast );
use TUI::Drivers::ColorAttr;
use TUI::Gadgets::Const qw( :cmXXXX );
use TUI::Views::DrawBuffer;
use TUI::Views::View;
use TUI::Views::Util qw( message );

sub TColorDisplay() { __PACKAGE__ }
sub name() { 'TColorDisplay' }
sub new_TColorDisplay { __PACKAGE__->from(@_) }

extends TView;

# declare global variables
our $colors     = "Colors";
our $groupText  = "~G~roup";
our $itemText   = "~I~tem";
our $forText    = "~F~oreground";
our $bakText    = "~B~ackground";
our $textText   = "Text ";
our $colorText  = "Color";
our $okText     = "O~K~";
our $cancelText = "Cancel";

# import global variables
use vars qw(
  $errorAttr
);
{
  no strict 'refs';
  *errorAttr = \${ TView . '::errorAttr' };
}

# protected attributes
has color => ( is => 'ro', default => sub { TColorAttr->new() } );
has text  => ( is => 'ro', default => sub { die 'required' } );

sub BUILDARGS {    # \%args (%args)
  state $sig = signature(
    method => 1,
    named => [
      bounds => Object,
      text   => Str, { alias => 'aText' },
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
  $self->{eventMask} |= evBroadcast;
  return;
}

sub from {    # $obj ($bounds, $aText)
  state $sig = signature(
    method => 1,
    pos    => [Object, Str],
  );
  my ( $class, @args ) = $sig->( @_ );
  return $class->new( bounds => $args[0], text => $args[1] );
}

sub DEMOLISH {    # void ($in_global_destruction)
  my ( $self, $in_global_destruction ) = @_;
  assert ( @_ == 2 );
  assert ( is_Object $self );
  $self->{text} = undef;
  return;
}

sub draw {    # void ()
  state $sig = signature(
    method => Object,
    pos    => [],
  );
  my ( $self ) = $sig->( @_ );
  my $c = 0+ $self->{color};
  my $b = TDrawBuffer->new();
  $c = $errorAttr 
    if $c == 0;
  my $len = length( $self->{text} );
  for ( my $i = 0; $i <= $self->{size}{x} / $len; $i++ ) {
    $b->moveStr( $i + $len, $self->{text}, $c );
  }
  $self->writeLine( 0, 0, $self->{size}{x}, $self->{size}{y}, $b );
  return;
}

sub handleEvent {    # void ($event)
  no warnings 'uninitialized';
  state $sig = signature(
    method => Object,
    pos    => [Object],
  );
  my ( $self, $event ) = $sig->( @_ );
  $self->SUPER::handleEvent( $event );
  if ( $event->{what} == evBroadcast ) {
    switch: for ( $event->{message}{command} ) {
      case: cmColorBackgroundChanged == $_ and do {
        $self->{color}->setBackground( $event->{message}{infoByte} & 0xf );
        $self->drawView();
        last;
      };
      case: cmColorForegroundChanged == $_ and do {
        $self->{color}->setForeground( $event->{message}{infoByte} & 0xf );
        $self->drawView();
        last;
      };
    }
  }
  return;
}

sub setColor {    # void ($aColor)
  state $sig = signature(
    method => Object,
    pos    => [Object],
  );
  my ( $self, $aColor ) = $sig->( @_ );
  $self->{color} = $aColor;
  message( $self->{owner}, evBroadcast, cmColorSet, 0+ $self->{color} );
  $self->drawView();
  return;
}

1

__END__

=pod

=head1 NAME

TColorDisplay - color preview view for the color selection dialog

=head1 HIERARCHY

  TObject
    TView
      TColorDisplay

=head1 SYNOPSIS

  use TUI::Gadgets;

  my $view = TColorDisplay->new(
    bounds => $bounds,
    text   => 'Text ',
  );

=head1 DESCRIPTION

C<TColorDisplay> displays a sample text using the currently selected color 
attribute.

It is typically embedded in a color selection dialog and provides a live 
preview of foreground and background color changes.

=head1 ATTRIBUTES

=over

=item color

Current color attribute (I<TColorAttr>, read-only).

=item text

Text displayed across the view (I<Str>, read-only).

=back

=head1 CONSTRUCTOR

=head2 new

  my $view = TColorDisplay->new(
    bounds => $bounds,
    text   => 'Text ',
  );

Creates a new color preview view.

=over

=item bounds

Bounding rectangle defining the position and size of the view
(I<TRect>).

=item text

Text displayed across the view (I<Str>).

=back

=head2 new_TColorDisplay

  my $view = new_TColorDisplay( $bounds, $text );

Factory-style constructor.

=head1 METHODS

=head2 draw

  $view->draw();

Draws the preview text using the current color attribute.

The configured text is repeated across the width of the view.

=head2 handleEvent

  $view->handleEvent($event);

Handles broadcast color selection events.

The view responds to:

=over

=item *

C<cmColorForegroundChanged>

=item *

C<cmColorBackgroundChanged>

=back

and updates the displayed color accordingly.

=head2 setColor

  $view->setColor($color);

Sets the current color attribute.

The view broadcasts a C<cmColorSet> message and redraws itself.

=head1 SEE ALSO

L<TColorDialog|TUI::Gadgets::TColorDialog>,
L<TView|TUI::Views::View>,
L<TColorSelector|TUI::Gadgets::ColorSelector>

=head1 AUTHORS

=over

=item * Borland International (original Turbo Vision design)

=item * J. Schneider <brickpool@cpan.org> (Perl implementation and maintenance)

=back

=head1 COPYRIGHT AND LICENSE

Copyright (c) 1990-1994, 1997 by Borland International

Copyright (c) 2026 the L</AUTHORS> as listed above.

This software is licensed under the MIT license (see the LICENSE file,
which is part of the distribution).

=cut
