use strict;
use warnings;

use Test::More;

BEGIN {
  use_ok 'TUI::Objects::Const';
  use_ok 'TUI::Objects::Object';
  use_ok 'TUI::Objects::Point';
  use_ok 'TUI::Objects::Rect';
  use_ok 'TUI::Objects::NSCollection';
  use_ok 'TUI::Objects::NSSortedCollection';
  use_ok 'TUI::Objects::Collection';
  use_ok 'TUI::Objects::SortedCollection';
  use_ok 'TUI::Objects::StringCollection';
  use_ok 'TUI::Objects::StringList';
  use_ok 'TUI::Objects::StrListMaker';
  use_ok 'TUI::Objects::Stream';
}

isa_ok( TObject->new(), TObject );
isa_ok( TPoint->new(), TPoint );
isa_ok( TRect->new(), TRect );
isa_ok( TNSCollection->new(), TNSCollection );
isa_ok( TNSSortedCollection->new(), TNSSortedCollection );
isa_ok( TCollection->new(), TCollection );
isa_ok( TSortedCollection->new(), TSortedCollection );
isa_ok( TStringCollection->new( limit => 0, delta => 0 ), TStringCollection );
isa_ok( TStringList->new(), TStringList );
isa_ok( TStrListMaker->new( strSize => 0, indexSize => 0 ), TStrListMaker );
isa_ok( TStream->new(), TStream );

done_testing();
