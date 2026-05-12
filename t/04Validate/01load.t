use strict;
use warnings;

use Test::More;

BEGIN {
  use_ok 'TUI::Validate::Const', qw( vsOk );
  use_ok 'TUI::Validate::Validator';
  use_ok 'TUI::Validate::PXPictureValidator';
}

isa_ok( TValidator->new(), TValidator );
isa_ok( TPXPictureValidator->new( pic => '##??', autoFill => !!0 ), 
  TPXPictureValidator );

done_testing();
