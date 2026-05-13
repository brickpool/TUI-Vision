use strict;
use warnings;

use Test::More;

BEGIN {
  use_ok 'TUI::Validate';
}

isa_ok( new_TValidator(), TValidator );
isa_ok( new_TPXPictureValidator( '##??', !!0 ), TPXPictureValidator );
isa_ok( new_TFilterValidator( 'abc' ), TFilterValidator );

done_testing();
