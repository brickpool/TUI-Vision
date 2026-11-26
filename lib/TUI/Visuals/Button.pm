package TUI::Visuals::Button;
# ABSTRACT: Button with a framed visual style

use 5.010;
use strict;
use warnings;

our $VERSION = '2.000003';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Exporter 'import';
our @EXPORT = qw(
  VButton
  new_VButton
);

use TUI::toolkit;
use TUI::toolkit::Types qw( :types );

use TUI::Dialogs::Button;
use TUI::Dialogs::Const qw( :bfXXXX );
use TUI::Drivers::Const qw( :evXXXX );
use TUI::Drivers::Util qw( cstrlen );
use TUI::Views::Const qw( :sfXXXX );
use TUI::Views::DrawBuffer;
use TUI::Views::Frame ();

sub VButton() { __PACKAGE__ }
sub name() { 'VButton' }
sub new_VButton { __PACKAGE__->from(@_) }

extends TButton;

sub drawState {    # void ($down)
  state $sig = signature(
    method => Object,
    pos    => [Bool],
  );
  my ( $self, $down ) = $sig->( @_ );

  my $width    = $self->{size}{x};
  my $height   = $self->{size}{y};
  return if $width <= 0 || $height <= 0;

  my $right    = $width - 1;
  my $disabled = $self->{state} & sfDisabled;
  my $offset   = !$disabled && $self->{amDefault} ? 9 : 0;

  my (
    $topLeft,    $top,    $topRight,
    $leftSide,            $rightSide,
    $bottomLeft, $bottom, $bottomRight,
  ) = map { 
    substr(
      $TUI::Views::Frame::frameChars,
      ord( substr( $TUI::Views::Frame::initFrame, $offset + $_, 1 ) ),
      1,
    )
  } ( 0, 1, 2, 3, 5, 6, 7, 8 );

  my ( $light, $dark, $face, $title );

  # Disabled: use the dialog's disabled button color
  if ( $disabled ) {
    $light = $dark = $face = $self->mapColor( 4 );
    $title = $self->getColor( 0x0404 );
  }

  # Enabled: use the standard button colors
  else {
    $light = $self->mapColor( 3 );
    $dark  = $self->mapColor( 1 );

    my ( $text, $shortcut ) = ( 1, 5 );

    if ( $self->{state} & sfActive ) {

      # Selected button
      if ( $self->{state} & sfSelected ) {
        ( $text, $shortcut ) = ( 3, 7 );
      }

      # Default button
      elsif ( $self->{amDefault} ) {
        ( $text, $shortcut ) = ( 2, 6 );
      }
    }

    $face  = $self->mapColor( $text );
    $title = $self->getColor( ( $shortcut << 8 ) | $text );
  }

  ( $light, $dark ) = ( $dark, $light )
    if $down && !$disabled;

  if ( $height == 1 && $down && !$disabled ) {
	  $title = ( ( $title & 0x0F0F ) << 4 ) | ( ( $title & 0xF0F0 ) >> 4 );
  }

  my $b = TDrawBuffer->new();

  my $length = cstrlen( $self->{title} );
  my $inset = $height == 1 && $width >= 4 ? 2 : 1;
  my $start = $self->{flags} & bfLeftJust
    ? $inset
    : int( ( $width - $length ) / 2 );

  $start = $inset if $start < $inset;

  my $titleRow = int( ( $height - 1 ) / 2 );
  for my $y ( 0 .. $height - 1 ) {
    my ( $fill, $fillColor, $left, $rightChar );
    if ( $height == 1 ) {
      ( $fill, $fillColor, $left, $rightChar ) = ( ' ', $face, '<', '>' );
    }
    elsif ( $y == 0 ) {
      # Top
      ( $fill, $fillColor, $left, $rightChar ) =
        ( $top, $light, $topLeft, $topRight );
    }
    elsif ( $y == $height - 1 ) {
      # Bottom
      ( $fill, $fillColor, $left, $rightChar ) =
        ( $bottom, $dark, $bottomLeft, $bottomRight );
    }
    else {
      # Middle
      ( $fill, $fillColor, $left, $rightChar ) =
        ( ' ', $face, $leftSide, $rightSide );
    }

    $b->moveChar( 0, $fill, $fillColor, $width );
    $b->moveCStr( $start, $self->{title}, $title )
      if $y == $titleRow && $width > 2;
    $b->putChar( 0, $left );
    $b->putAttribute( 0, $height == 1 ? $face : $light );
    if ( $width > 1 ) {
      $b->putChar( $right, $rightChar );
      $b->putAttribute( $right, $height == 1 ? $face : $dark );
    }
    $self->writeLine( 0, $y, $width, 1, $b );
  }

  return;
}

sub handleEvent {    # void ($event)
  state $sig = signature(
    method => Object,
    pos    => [Object],
  );
  my ( $self, $event ) = $sig->( @_ );

  if ( $self->{size}{y} != 1 || $event->{what} != evMouseDown ) {
    $self->SUPER::handleEvent( $event );
    return;
  }

  my $clickRect = $self->getExtent();
  my $mouse = $self->makeLocal( $event->{mouse}{where} );
  if ( !$clickRect->contains( $mouse ) ) {
    $self->clearEvent( $event );
    return;
  }

  TUI::Views::View::handleEvent( $self, $event )
    if $self->{flags} & bfGrabFocus;
  return if $event->{what} != evMouseDown;

  if ( !( $self->{state} & sfDisabled ) ) {
    my $down = false;
    do {
      $mouse = $self->makeLocal( $event->{mouse}{where} );
      if ( !$down != !$clickRect->contains( $mouse ) ) {
        $down = !$down;
        $self->drawState( $down );
      }
    } while ( $self->mouseEvent( $event, evMouseMove ) );
    if ( $down ) {
      $self->press();
      $self->drawState( false );
    }
  }
  $self->clearEvent( $event );
  return;
}

1;
