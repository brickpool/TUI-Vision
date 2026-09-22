use strict;
use warnings;

use Test::More;

BEGIN {
  use_ok 'TUI::Objects::Rect';
  use_ok 'TUI::Gadgets::PrintConstants';
  use_ok 'TUI::Gadgets::EventViewer';
  use_ok 'TUI::Gadgets::HeapView';
  use_ok 'TUI::Gadgets::ClockView';
  use_ok 'TUI::Gadgets::LineCollection';
  use_ok 'TUI::Gadgets::FileViewer';
  use_ok 'TUI::Gadgets::FileWindow';
}

isa_ok(
  TEventViewer->new( bounds => TRect->new(), bufSize => 0 ), TEventViewer()
);
isa_ok( THeapView->new( bounds => TRect->new() ), THeapView() );
isa_ok( TClockView->new( bounds => TRect->new() ), TClockView() );
isa_ok( TLineCollection->new( limit => 10, delta => 5 ), TLineCollection() );
isa_ok( TFileViewer->new( bounds => TRect->new(), hScrollBar => undef, 
  vScrollBar => undef, fileName => $0 ), TFileViewer() );
isa_ok( TFileWindow->new( fileName => $0 ), TFileWindow() );

done_testing();
