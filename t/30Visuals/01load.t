use strict;
use warnings;

use Test::More;

BEGIN {
  use_ok 'TUI::Objects::Rect';
  use_ok 'TUI::Visuals::Button';
  use_ok 'TUI::Visuals::InputLine';
}

isa_ok(
  VButton->new(
    bounds  => TRect->new(),
    title   => 'Button',
    command => 300,
    flags   => 0,
  ),
  VButton
);
isa_ok( new_VButton( TRect->new(), 'Button', 300, 0 ), VButton );
isa_ok(
  VInputLine->new( bounds => TRect->new(), maxLen => 20, label => 'Name' ),
  VInputLine
);

done_testing();
