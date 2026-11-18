use strict;
use warnings;

use Test::More;

BEGIN {
  use_ok 'TUI::Help';
}

isa_ok( new_TRefTable( 10, 5 ), TRefTable() );
isa_ok( new_THelpIndex(), THelpIndex() );

done_testing();
