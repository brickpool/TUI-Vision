use strict;
use warnings;

use Test::More;

BEGIN {
  use_ok 'TUI::Validate';
}

isa_ok( new_TValidator(), TValidator );
isa_ok( new_TPXPictureValidator( '##??', !!0 ), TPXPictureValidator );

done_testing();
