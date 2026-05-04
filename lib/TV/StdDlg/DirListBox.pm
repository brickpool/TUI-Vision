package TV::StdDlg::DirListBox;
# ABSTRACT: TListBox subclass providing directory listing for TChDirDialog

use 5.010;
use strict;
use warnings;

our $VERSION = '2.000_001';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Exporter 'import';

our @EXPORT = qw(
  TDirListBox
  new_TDirListBox
);

use TV::toolkit;
use TV::toolkit::Types qw(
  Maybe
  :types
);

use TV::Const qw( EOS );
use TV::Drivers::Const qw( evBroadcast );
use TV::Dialogs::ListBox;
use TV::StdDlg::Const qw(
  cmChangeDir
  FA_DIREC
);
use TV::StdDlg::Dos;
use TV::StdDlg::Dir qw(
  findfirst
  findnext
  getdisk
);
use TV::StdDlg::DirEntry;
use TV::StdDlg::DirCollection;
use TV::StdDlg::Util qw( driveValid );
use TV::Views::Const qw( sfFocused );
use TV::Views::Util qw( message );

sub TDirListBox() { __PACKAGE__ }
sub name() { 'TDirListBox' }
sub new_TDirListBox { __PACKAGE__->from( @_ ) }

extends TListBox;

# declare global variables
our $pathDir   =   "└─┬";
our $firstDir  =     "└┬─";
our $middleDir =     " ├─";
our $lastDir   =     " └─";
our $drives    = "Drives";
our $graphics  =   "└├─";

# private attributes
has dir => ( is => 'bare', default => EOS );
has cur => ( is => 'bare', default => 0 );

# private methods
my (
  $showDrives,
  $showDirs,
);

sub BUILDARGS {    # \%args (%args)
  state $sig = signature(
    method => 1,
    named  => [
      bounds     => Object,
      vScrollBar => Maybe[Object], { alias => 'aScrollBar' },
    ],
    caller_level => +1,
  );
  my ( $class, $args ) = $sig->( @_ );
  local $Carp::CarpLevel = $Carp::CarpLevel + 1;
  return $class->SUPER::BUILDARGS(
    bounds     => $args->{bounds},
    numCols    => 1,
    vScrollBar => $args->{vScrollBar},
  );
}

sub from {    # $obj ($bounds, $aVScrollBar|undef)
  state $sig = signature(
    method => 1,
    pos    => [Object, Maybe[Object]],
  );
  my ( $class, @args ) = $sig->( @_ );
  return $class->new( bounds => $args[0], vScrollBar => $args[2] );
}

sub DEMOLISH {    # void ($in_global_destruction)
  my ( $self, $in_global_destruction ) = @_;
  assert ( @_ == 2 );
  assert ( is_Object $self );
  alias: for my $list ( $self->{items} ) {
  $self->destroy( $list );
  return;
  } #/ alias: 
}

sub getText {    # void (\$text, $item, $maxChars)
  state $sig = signature(
    method => Object,
    pos    => [ScalarRef, Int, Int],
  );
  my ( $self, $text, $item, $maxChars ) = $sig->( @_ );
  $$text = $self->list()->at( $item )->text();
  substr( $$text, $maxChars ) = EOS if length $$text > $maxChars;
  return;
}

sub isSelected {    # $bool ($item)
  state $sig = signature(
    method => Object,
    pos    => [PositiveOrZeroInt],
  );
  my ( $self, $item ) = $sig->( @_ );
  return $item == $self->{cur};
}

sub selectItem {    # void ($item)
  state $sig = signature(
    method => Object,
    pos    => [PositiveOrZeroInt],
  );
  my ( $self, $item ) = $sig->( @_ );
  message( $self->{owner}, evBroadcast, cmChangeDir, 
    $self->list()->at( $item ) );
  return;
}

sub newDirectory {    # void ($str)
  state $sig = signature(
    method => Object,
    pos    => [Str],
  );
  my ( $self, $str ) = $sig->( @_ );
  $self->{dir} = $str;
  my $dirs = TDirCollection->new( limit => 5, delta => 5 );
  $dirs->insert( TDirEntry->new(
    displayText => $drives, directory => $drives )
  );
  if ( $self->{dir} eq $drives ) {
    $self->$showDrives( $dirs );
  } 
  else {
    $self->$showDirs( $dirs );
  }
  $self->newList( $dirs );
  $self->focusItem( $self->{cur} );
  return;
}

sub setState {    # void ($aState, $enable)
  state $sig = signature(
    method => Object,
    pos    => [PositiveOrZeroInt, Bool],
  );
  my ( $self, $aState, $enable ) = $sig->( @_ );

  $self->SUPER::setState( $aState, $enable );
  if ( $aState & sfFocused ) {
    message( $self->{owner}, evBroadcast, cmChangeDir, 
      $self->list()->at( $self->{cur} ) );
  }
  return;
}

sub list {    # $dirCollection ()
  goto &TV::Dialogs::ListBox::list;
}

$showDrives = sub {    # void ($dirs)
  my ( $self, $dirs ) = @_;
  assert ( @_ == 2 );
  assert ( is_Object $self );
  assert ( is_Object $dirs );

  my $isFirst = true;
  my $oldc    = "0:\\";
  for my $c ( 'A' .. 'Z' ) {
    if ( $c lt 'C' || driveValid( $c ) ) {
      if ( substr( $oldc, 0, 1 ) ne '0' ) {
        my $s;
        if ( $isFirst ) {
          $s = $firstDir . substr( $oldc, 0, 1 );
          $isFirst = false;
        }
        else {
          $s = $middleDir . substr( $oldc, 0, 1 );
        }
        $dirs->insert(
          TDirEntry->new( displayText => $s, directory => $oldc )
        );
      }
      if ( ord( $c ) == getdisk() + ord( 'A' ) ) {
        $self->{cur} = $dirs->getCount();
      }
      substr( $oldc, 0, 1 ) = $c;
    } #/ if ( $c lt 'C' || driveValid...)
  } #/ for my $c ( 'A' .. 'Z' )

  if ( substr( $oldc, 0, 1 ) ne '0' ) {
    my $s = $lastDir . substr( $oldc, 0, 1 );
    $dirs->insert( TDirEntry->new( displayText => $s, directory => $oldc ) );
  }
  return;
};

$showDirs = sub {    # void ($dirs)
  my ( $self, $dirs ) = @_;
  assert ( @_ == 2 );
  assert ( is_Object $self );
  assert ( is_Object $dirs );

  state $indentSize = 2;
  my $indent = $indentSize;
  my $org    = $pathDir;

  state $endPos = 3;
  my $curDir = $self->{dir};
  $dirs->insert( TDirEntry->new(
    displayText => $org, 
    directory   => substr( $curDir, 0, $endPos ),
  ));

  $curDir = substr( $curDir, $endPos );
  while ( ( my $pos = index( $curDir, '\\' ) ) != -1 ) {
    $dirs->insert( TDirEntry->new(
      displayText => ( ' ' x $indent ) . $org, 
      directory   => $self->{dir},
    ));
    $curDir = substr( $curDir, $pos + 1 );
    $indent += $indentSize;
  }

  $self->{cur} = $dirs->getCount() - 1;

  my $basePath = $self->{dir};
  $basePath =~ s/\\[^\\]*$//;
  $basePath .= '\\';
  my $path = $basePath . '*.*';

  my $isFirst = true;
  my $ff  = ffblk->new();
  my $res = findfirst( $path, $ff, FA_DIREC );
  while ( $res == 0 ) {
    if ( ( $ff->ff_attrib & FA_DIREC )
      && substr( $ff->ff_name, 0, 1 ) ne '.'
    ) {
      if ( $isFirst ) {
        $org     = $firstDir;
        $isFirst = false;
      }
      else {
        $org = $middleDir;
      }
      $path = $basePath . $ff->ff_name;
      $dirs->insert( TDirEntry->new(
        displayText => ( ' ' x $indent ) . $org,
        directory   => $path,
      ));
    }
    $res = findnext( $ff );
  } #/ while ( $res == 0 )

  alias: for my $p ( $dirs->at( $dirs->getCount() - 1 )->{displayText} ) {
  my @graphics = split //, $graphics;
  my $i = index( $p, $graphics[0] );
  if ( $i < 0 ) {
    $i = index( $p, $graphics[1] );
    if ( $i >= 0 ) {
      substr( $p, $i, 1 ) = $graphics[0];
    }
  }
  else {
    substr( $p, $i + 1, 1 ) = $graphics[2];
    substr( $p, $i + 2, 1 ) = $graphics[2];
  }
  return;
  } #/ alias:
};

1
