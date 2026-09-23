package TUI::Gadgets::FileViewer;
# ABSTRACT: File viewer gadget for TVision applications

use 5.010;
use strict;
use warnings;

our $VERSION = '2.000001';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Exporter 'import';
our @EXPORT = qw(
  TFileViewer
  new_TFileViewer
);

use Carp ();
use IO::File;
use List::Util qw( max );
use TUI::toolkit;
use TUI::toolkit::Types qw(
  Maybe
  :is
  :types
);

use TUI::Const qw( EOS );
use TUI::Gadgets::Const qw( maxLineLength );
use TUI::Gadgets::LineCollection;
use TUI::Memory qw( lowMemory );
use TUI::MsgBox::Const qw( :mfXXXX );
use TUI::MsgBox::MsgBoxText qw( messageBox );
use TUI::Views::Const qw(
  gfGrowHiX
  gfGrowHiY
  sfExposed
);
use TUI::Views::DrawBuffer;
use TUI::Views::Scroller;

sub TFileViewer() { __PACKAGE__ }
sub name() { 'TFileViewer' }
sub new_TFileViewer { __PACKAGE__->from(@_) }

extends TScroller;

# public attributes
has fileName  => ( is => 'rw', default => sub { die 'required' } );
has fileLines => ( is => 'rw' );
has isValid   => ( is => 'rw', default => !!0 );

sub BUILDARGS {    # \%args (%args)
  state $sig = signature(
    method => 1,
    named  => [
      bounds     => Object,
      hScrollBar => Maybe[Object], { alias => 'aHScrollBar' },
      vScrollBar => Maybe[Object], { alias => 'aVScrollBar' },
      fileName   => Str,           { alias => 'aFileName'   },
    ],
    caller_level => +1,
  );
  my ( $class, $args1 ) = $sig->( @_ );
  local $Carp::CarpLevel = $Carp::CarpLevel + 1;
  my $args2 = $class->SUPER::BUILDARGS(
    bounds     => $args1->{bounds},
    hScrollBar => $args1->{hScrollBar},
    vScrollBar => $args1->{vScrollBar},
  );
  return { %$args1, %$args2 };
}

sub BUILD {    # void (\%args)
  my ( $self, $args ) = @_;
  assert ( @_ == 2 );
  assert ( is_Object $self );
  assert ( is_HashRef $args );
  $self->{growMode} |= gfGrowHiX | gfGrowHiY;
  $self->{isValid} = true;
  $self->{fileName} = '';
  $self->readFile( $args->{fileName} );
  return;
}

sub from {    # $fileView ($bounds, $aHScrollBar|undef, $aVScrollBar|undef, $aFileName)
  state $sig = signature(
    method => 1,
    pos => [Object, Maybe[Object], Maybe[Object], Str],
  );
  my ( $class, @args ) = $sig->( @_ );
  return $class->new( bounds => $args[0], hScrollBar => $args[1], 
    vScrollBar => $args[2], fileName => $args[3] );
}

sub DEMOLISH {    # void ($in_global_destruction)
  my ( $self, $in_global_destruction ) = @_;
  assert ( @_ == 2 );
  assert ( is_Object $self );
  assert ( is_Bool $in_global_destruction );
  undef $self->{fileName};
  $self->destroy( $self->{fileLines} );
  return;
}

sub draw {    # void ()
  state $sig = signature(
    method => Object,
    pos    => [],
  );
  my ( $self ) = $sig->( @_ );
  my $p;

  my $c = $self->getColor( 0x0301 );
  for ( my $i = 0 ; $i < $self->{size}{y} ; $i++ ) {
    my $b = TDrawBuffer->new();
    $b->moveChar( 0, ' ', $c, $self->{size}{x} );
    if ( $self->{delta}{y} + $i < $self->{fileLines}->getCount() ) {
      my $s;
      $p = $self->{fileLines}->at( $self->{delta}{y} + $i );
      if ( !$p || length( $p ) < $self->{delta}{x} ) {
        $s = EOS;
      }
      else {
        $s = substr( $p, $self->{delta}{x}, $self->{size}{x} );
        if ( length( substr( $p, $self->{delta}{x} ) ) > $self->{size}{x} ) {
          substr( $s, 0, $self->{size}{x} ) = EOS;
        }
      }
      $b->moveStr( 0, substr( $s, 0, maxLineLength ), $c );
    }
    $self->writeBuf( 0, $i, $self->{size}{x}, 1, $b );
  }
  return;
}

sub readFile {    # void ($fName)
  state $sig = signature(
    method => 1,
    pos    => [Str],
  );
  my ( $self, $fName ) = $sig->( @_ );
  $self->{limit}{x}  = 0;
  $self->{fileName}  = $fName;
  $self->{fileLines} = TLineCollection->new( limit => 5, delta => 5 );
  my $fileToView = IO::File->new( $fName, 'r' );
  if ( !defined $fileToView ) {
    messageBox( "Invalid drive or directory", mfError | mfOKButton );
    $self->{isValid} = false;
  }
  else {
    my $line;
    while ( !lowMemory()
      && !$fileToView->eof()
      && defined( $line = $fileToView->getline() )
    ) {
      $line =~ s/\r?\n$//;    # truncate trailing newline
      $self->{limit}{x} = max( $self->{limit}{x}, length( $line ) );
      $self->{fileLines}->insert( $line );
    }
    $self->{isValid} = true;
  }
  $self->{limit}{y} = $self->{fileLines}->getCount();
  return;
}

sub setState {    # void ($aState, $enable)
  state $sig = signature(
    method => Object,
    pos    => [PositiveOrZeroInt, Bool],
  );
  my ( $self, $aState, $enable ) = $sig->( @_ );
  $self->SUPER::setState( $aState, $enable );
  if ( $enable && ( $aState & sfExposed ) ) {
    $self->setLimit( $self->{limit}{x}, $self->{limit}{y} );
  }
  return;
}

sub scrollDraw {    # void ()
  state $sig = signature(
    method => Object,
    pos    => [],
  );
  my ( $self ) = $sig->( @_ );
  $self->SUPER::scrollDraw();
  $self->draw();
  return;
}

sub valid {    # $bool ($command)
  state $sig = signature(
    method => Object,
    pos    => [PositiveOrZeroInt],
  );
  my ( $self, undef ) = $sig->( @_ );
  return $self->{isValid}
}

1
