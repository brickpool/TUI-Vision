use strict;
use warnings;

use Test::More;

BEGIN {
  use_ok 'TUI::Objects::Rect';
  use_ok 'TUI::Gadgets::Const', qw( csBackground );
  use_ok 'TUI::Gadgets::PrintConstants';
  use_ok 'TUI::Gadgets::EventViewer';
  use_ok 'TUI::Gadgets::HeapView';
  use_ok 'TUI::Gadgets::ClockView';
  use_ok 'TUI::Gadgets::ColorDisplay';
  use_ok 'TUI::Gadgets::ColorItem';
  use_ok 'TUI::Gadgets::ColorGroup';
  use_ok 'TUI::Gadgets::ColorSelector';
  use_ok 'TUI::Gadgets::MonoSelector';
  use_ok 'TUI::Gadgets::ColorGroupList';
  use_ok 'TUI::Gadgets::ColorItemList';
}

isa_ok(
  TEventViewer->new( bounds => TRect->new(), bufSize => 0 ), TEventViewer()
);
isa_ok( THeapView->new( bounds => TRect->new() ), THeapView() );
isa_ok( TClockView->new( bounds => TRect->new() ), TClockView() );
isa_ok( TColorDisplay->new( bounds => TRect->new(), aText => 'Text' ), 
  TColorDisplay() );
isa_ok( TColorItem->new( name => 'item', index => 0 ), TColorItem() );
isa_ok( TColorGroup->new( name => 'group' ), TColorGroup() );
isa_ok( TColorSelector->new( bounds => TRect->new(), selType => csBackground ), 
  TColorSelector() );
isa_ok( TMonoSelector->new( bounds => TRect->new() ), TMonoSelector() );
isa_ok( TColorGroupList->new( bounds => TRect->new(), scrollBar => undef, 
  groups => undef ), TColorGroupList() );
isa_ok( TColorItemList->new( bounds => TRect->new(), scrollBar => undef, 
  items => undef ), TColorItemList() );

done_testing();
