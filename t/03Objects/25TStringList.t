use strict;
use warnings;

use File::Temp qw( tempdir );
use Test::More;

BEGIN {
  use_ok 'TUI::Objects';
  use_ok 'TUI::Objects::StrListMaker';
}

my $includePath = tempdir( CLEANUP => 1 );
local $TUI::Objects::StrListMaker::includePath = $includePath;
local $TUI::Objects::StrListMaker::resourceClass =
  'TUI::Objects::TestStringList::L10N';
local $TUI::Objects::StrListMaker::languageTag = 'de';

my $tag = $TUI::Objects::StrListMaker::languageTag;
my $otherTag = 'fr';

my $maker = new_TStrListMaker( 128, 16 );
$maker->put( 1, 'Pass, Do not Go!' );
$maker->put( 2, 'Collect $500!' );
$maker->put( 2, 'Replaced value' );
$maker->put( 100, q(It's ready.) );
$maker->put( 65535, "Last\nentry" );

$maker->store($tag);

my $list = new_TStringList();
is( $list->load($tag), $list, 'loads generated resource' );

is( $list->get(1), 'Pass, Do not Go!', 'gets string by key' );
is( $list->get(2), 'Collect $500!', 'gets another string by key' );
is( $list->get(3), '', 'unknown key returns empty string' );
is( $list->get(100), q(It's ready.), 'preserves quotes in strings' );
is( $list->get(65535), "Last\nentry", 'supports the upper ushort key' );

my $otherMaker = new_TStrListMaker( 128, 16 );
$otherMaker->put( 1, 'Another resource' );
$otherMaker->store($otherTag);
my $otherList = new_TStringList();
$otherList->load($otherTag);

is( $otherList->get(1), 'Another resource', 'reads a second resource' );
is( $list->get(1), 'Pass, Do not Go!', 'keeps the first resource independent' );

done_testing();
