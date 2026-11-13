use strict;
use warnings;

use Test::More;

BEGIN {
  use_ok 'TUI::Objects::Rect';
  use_ok 'TUI::Editors';
}

isa_ok( new_TIndicator( TRect->new() ), TIndicator() );

done_testing();
