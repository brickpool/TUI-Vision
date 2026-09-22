package TUI::Gadgets::FileWindow;
# ABSTRACT: TFileWindow is a file window for displaying file contents.

use 5.010;
use strict;
use warnings;

our $VERSION = '2.000001';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Exporter 'import';
our @EXPORT = qw(
  TFileWindow
  new_TFileWindow
);

use Carp ();
use TUI::toolkit;
use TUI::toolkit::Types qw(
  :is
  :types
);

use TUI::App::Program qw( $deskTop );
use TUI::Gadgets::FileViewer;
use TUI::Objects::Rect;
use TUI::Views::Const qw(
  ofTileable
  :sbXXXX
);
use TUI::Views::Window;

sub TFileWindow() { __PACKAGE__ }
sub new_TFileWindow { __PACKAGE__->from(@_) }

extends TWindow;

# declaration local variables
my $winNumber = 0;

sub BUILDARGS {    # \%args (%args)
  state $sig = signature(
    method => 1,
    named  => [
      fileName => Str,
    ],
    caller_level => +1,
  );
  my ( $class, $args1 ) = $sig->( @_ );
  local $Carp::CarpLevel = $Carp::CarpLevel + 1;
  my $args2 = $class->SUPER::BUILDARGS(
    bounds => $deskTop ? $deskTop->getExtent() : TRect->new(),
    title  => $args1->{fileName},
    number => $winNumber++,
  );
  return { %$args1, %$args2 };
}

sub BUILD {    # void (\%args)
  my ( $self, $args ) = @_;
  assert ( @_ == 2 );
  assert ( is_Object $self );
  assert ( is_HashRef $args );
  $self->{options} |= ofTileable;
  my $r = $self->getExtent();
  $r->grow( -1, -1 );
  $self->insert(
    TFileViewer->new(
      bounds     => $r,
      hScrollBar => $self->standardScrollBar( sbHorizontal | sbHandleKeyboard ),
      vScrollBar => $self->standardScrollBar( sbVertical | sbHandleKeyboard ),
      fileName   => $args->{fileName},
    )
  );
  return;
}

sub from {    # $fileWindow ($fileName)
  state $sig = signature(
    method => 1,
    pos => [Str],
  );
  my ( $class, $fileName ) = $sig->( @_ );
  return $class->new( fileName => $fileName );
}

1
