use strict;
use warnings;

use Test::More;

BEGIN {
  use_ok 'TUI::Objects::Rect';
  use_ok 'TUI::Gadgets';
}

isa_ok( new_TEventViewer( TRect->new(), 0 ), TEventViewer() );
isa_ok( new_THeapView( TRect->new() ), THeapView() );
isa_ok( new_TClockView( TRect->new() ), TClockView() );
isa_ok( new_TColorDisplay( TRect->new(), 'Text' ), TColorDisplay() );
isa_ok( new_TColorItem( 'item', 0 ), TColorItem() );
isa_ok( new_TColorGroup( 'group' ), TColorGroup() );
isa_ok( new_TColorSelector( TRect->new(), csBackground ), TColorSelector() );
isa_ok( new_TMonoSelector( TRect->new() ), TMonoSelector() );
isa_ok( new_TColorGroupList( TRect->new(), undef, undef ), TColorGroupList() );

done_testing();
