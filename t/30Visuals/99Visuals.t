use strict;
use warnings;

use Test::More;

BEGIN {
  use_ok 'TUI::Objects::Rect';
  use_ok 'TUI::Visuals';
}

isa_ok( new_VButton( TRect->new(), 'Button', 300, 0 ), VButton );
isa_ok( new_VInputLine( TRect->new(), 20, 'Name' ), VInputLine );

done_testing();
