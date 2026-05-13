use strict;
use warnings;

use Test::More;

BEGIN {
  use_ok 'TUI::Validate';
}

isa_ok( new_TValidator(), TValidator );
isa_ok( new_TPXPictureValidator( '##??', !!0 ), TPXPictureValidator );
isa_ok( new_TFilterValidator( undef ), TFilterValidator );
isa_ok( new_TRangeValidator( 0, 100 ), TRangeValidator );
isa_ok( new_TLookupValidator(), TLookupValidator );

done_testing();
