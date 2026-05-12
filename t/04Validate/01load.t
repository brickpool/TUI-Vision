use strict;
use warnings;

use Test::More;

BEGIN {
  use_ok 'TUI::Validate::Const', qw( vsOk );
  use_ok 'TUI::Validate::Validator';
}

isa_ok( TValidator->new(), TValidator );

done_testing();
