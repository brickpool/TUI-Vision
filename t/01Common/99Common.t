use strict;
use warnings;

use Test::More;

BEGIN {
  use_ok 'TUI::Common';
}

ok( defined &INT_MAX, 'INT_MAX imported' );

done_testing();
