use strict;
use warnings;

use File::Temp qw( tempfile );
use Storable qw( freeze thaw );
use Test::More;

BEGIN {
  use_ok 'TUI::Objects::Rect';
  use_ok 'TUI::Gadgets::FileViewer';
  use_ok 'TUI::Gadgets::FileWindow';
  use_ok 'TUI::Gadgets::EventViewer';
}

subtest 'TFileViewer Storable roundtrip' => sub {
  my ( $fileHandle, $fileName ) = tempfile();
  print {$fileHandle} "First line\nA longer second line\nLast line\n";
  close $fileHandle;

  my $viewer = TFileViewer->new(
    bounds     => TRect->new( ax => 3, ay => 4, bx => 23, by => 9 ),
    hScrollBar => undef,
    vScrollBar => undef,
    fileName   => $fileName,
  );
  $viewer->{delta}{x} = 2;
  $viewer->{delta}{y} = 1;

  my $restored = thaw( freeze( $viewer ) );
  isa_ok( $restored, TFileViewer );
  is_deeply( $restored->{origin}, { x => 3,  y => 4 }, 'preserves origin' );
  is_deeply( $restored->{size},   { x => 20, y => 5 }, 'preserves size' );
  is( $restored->{fileName}, $fileName, 'preserves file name' );
  ok( $restored->isValid(), 'restores valid file state' );
  is( $restored->{fileLines}->getCount(), 3, 'reloads all file lines' );
  is( $restored->{fileLines}->at( 0 ), 'First line', 'restores first line' );
  is( $restored->{fileLines}->at( 1 ), 'A longer second line',
    'restores second line' );
  is( $restored->{limit}{x}, length( 'A longer second line' ),
    'recalculates horizontal limit' );
  is( $restored->{limit}{y}, 3, 'recalculates vertical limit' );
  is_deeply( $restored->{delta}, { x => 2, y => 1 }, 'preserves scroll delta' );

  unlink $fileName;
}; #/ 'TFileViewer Storable roundtrip' => sub

subtest 'TFileWindow Storable roundtrip' => sub {
  my ( $fileHandle, $fileName ) = tempfile();
  print {$fileHandle} "Window line one\nWindow line two\n";
  close $fileHandle;

  my $window = TFileWindow->new( fileName => $fileName );
  my $restored = thaw( freeze( $window ) );
  isa_ok( $restored, TFileWindow );
  is( $restored->{title}, $fileName, 'preserves window title' );

  my $viewer;
  $restored->forEach( sub {
    $viewer = $_[0]
      if $_[0]->isa( TFileViewer );
  }, undef );
  isa_ok( $viewer, TFileViewer );
  is( $viewer->{fileName}, $fileName, 'restores viewer file name' );
  ok( $viewer->isValid(), 'restores valid viewer state' );
  is( $viewer->{fileLines}->getCount(), 2, 'restores file lines' );
  is( $viewer->{fileLines}->at( 0 ), 'Window line one', 'restores first line' );
  is( $viewer->{fileLines}->at( 1 ), 'Window line two', 'restores second line' );

  unlink $fileName;
}; #/ 'TFileWindow Storable roundtrip' => sub

subtest 'TEventViewer Storable roundtrip' => sub {
  my $viewer = TEventViewer->new(
    bounds  => TRect->new( ax => 3, ay => 4, bx => 33, by => 14 ),
    bufSize => 256,
  );
  $viewer->{stopped}    = 1;
  $viewer->{eventCount} = 12;

  my $restored = thaw( freeze( $viewer ) );
  isa_ok( $restored, TEventViewer );
  is_deeply( $restored->{origin}, { x => 3,  y => 4  }, 'preserves origin' );
  is_deeply( $restored->{size},   { x => 30, y => 10 }, 'preserves size' );
  is( $restored->{bufSize}, 256, 'preserves terminal buffer size' );
  ok( !$restored->{stopped}, 'resets stopped state' );
  is( $restored->{eventCount}, 0, 'resets event count' );
  is( $restored->{title}, 'Event Viewer', 'restores active title' );
  isa_ok( $restored->{scrollBar}, 'TUI::Views::ScrollBar' );
  isa_ok( $restored->{interior}, 'TUI::TextView::Terminal' );
  is( $restored->{interior}{bufSize}, 256, 'recreates terminal with saved size' );
}; #/ 'TEventViewer Storable roundtrip' => sub

done_testing();