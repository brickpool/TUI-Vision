use strict;
use warnings;

use File::Temp qw( tempdir );
use Test::More;
use Test::Exception;
use Storable qw( freeze thaw );

BEGIN {
  require_ok 'UNIVERSAL::Object';
  use_ok 'TUI::Objects::Point';
  use_ok 'TUI::Objects::Rect';
  use_ok 'TUI::Objects::NSCollection';
  use_ok 'TUI::Objects::StringCollection';
  use_ok 'TUI::Objects::StringList';
  use_ok 'TUI::Objects::StrListMaker';
}

my $includePath = tempdir( CLEANUP => 1 );
local $TUI::Objects::StrListMaker::includePath = $includePath;
local $TUI::Objects::StrListMaker::resourceClass =
  'TUI::Objects::TestStorableStringList::L10N';
local $TUI::Objects::StrListMaker::languageTag = 'de';
my $tag = $TUI::Objects::StrListMaker::languageTag;

{
  package ThawProbe;
  our @ISA = ( 'TUI::Objects::NSCollection' );
  sub STORABLE_freeze { 'payload' }
}

subtest 'Test TPoint serialization and deserialization' => sub {
  my $point = TPoint->new( x => 10, y => 20 );
  my $blob  = freeze( $point );
  my $p     = thaw( $blob );
  isa_ok( $p, TPoint );
  is( $p->{x}, 10, 'Thawed TPoint has the original x coordinate' );
  is( $p->{y}, 20, 'Thawed TPoint has the original y coordinate' );
};

subtest 'Test TRect serialization and deserialization' => sub {
  my $rect = TRect->new(
    ax => 10,
    ay => 20,
    bx => 30,
    by => 40,
  );
  my $blob = freeze( $rect );
  my $r = thaw( $blob );
  isa_ok( $r, TRect );
  is( $r->{a}{x}, 10, 'Thawed TRect has the original a.x coordinate' );
  is( $r->{a}{y}, 20, 'Thawed TRect has the original a.y coordinate' );
  is( $r->{b}{x}, 30, 'Thawed TRect has the original b.x coordinate' );
  is( $r->{b}{y}, 40, 'Thawed TRect has the original b.y coordinate' );
};

subtest 'Test TNSCollection Storable hooks' => sub {
  my $obj = TNSCollection->new();
  isa_ok( $obj, TNSCollection, 'new() creates an object of correct class' );

  can_ok( TNSCollection, qw( STORABLE_freeze STORABLE_attach ) );

  throws_ok { 
    $SIG{__WARN__} = sub {}; 
    freeze( $obj ) 
  } qr/Unimplemented/, 'STORABLE_freeze reports that it is unimplemented';

  my $serialized = freeze( bless {}, 'ThawProbe' );
  throws_ok { thaw( $serialized ) } qr/Unimplemented/,
    'STORABLE_attach reports that it is unimplemented';
};

subtest 'TStringCollection Storable roundtrip' => sub {
  my $collection = TStringCollection->new( limit => 10, delta => 5 );
  $collection->insert( 'beta' );
  $collection->insert( 'alpha' );
  $collection->insert( 'gamma' );

  my $restored = thaw( freeze( $collection ) );
  isa_ok( $restored, TStringCollection );
  is( $restored->{count}, 3, 'Storable restores the collection count' );
  is( $restored->at( 0 ), 'alpha', 'Storable preserves the first sorted item' );
  is( $restored->at( 1 ), 'beta', 'Storable preserves the second sorted item' );
  is( $restored->at( 2 ), 'gamma', 'Storable preserves the third sorted item' );
};

subtest 'TStringList Storable roundtrip' => sub {
  my $maker = new_TStrListMaker( 128, 16 );
  $maker->put( 1, 'Pass, Do not Go!' );
  $maker->put( 2, 'Collect $500!' );
  $maker->store($tag);

  my $list = TUI::Objects::StringList->new();
  $list->load($tag);

  is( $list->get(1), 'Pass, Do not Go!', 'loads strings stored by the maker' );

  my $restored = thaw( freeze($list) );
  isa_ok( $restored, 'TUI::Objects::StringList' );
  is( $restored->get(2), 'Collect $500!', 'Storable preserves list strings' );
};

done_testing();
