use strict;
use warnings;

use Test::More;

BEGIN {
  use_ok 'TUI::Objects::Rect';
  use_ok 'TUI::Editors::Const';
  use_ok 'TUI::Editors::Indicator';
}

isa_ok( TIndicator->new( bounds => TRect->new() ), TIndicator() );

done_testing();
