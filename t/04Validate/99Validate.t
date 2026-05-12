use strict;
use warnings;

use Test::More;

BEGIN {
  use_ok 'TUI::Validate';
}

isa_ok( new_TValidator(), TValidator );

done_testing();
