use strict;
use warnings;

use Test::More;

BEGIN {
  use_ok 'TUI::Validate::Const', qw( vsOk );
  use_ok 'TUI::Validate::Validator';
  use_ok 'TUI::Validate::PXPictureValidator';
  use_ok 'TUI::Validate::FilterValidator';
  use_ok 'TUI::Validate::RangeValidator';
}

isa_ok( TValidator->new(), TValidator );
isa_ok( TPXPictureValidator->new( pic => '##??', autoFill => !!0 ), 
  TPXPictureValidator );
isa_ok( TFilterValidator->new( validChars => 'abc' ), TFilterValidator );
isa_ok( TRangeValidator->new( min => 0, max => 100 ), TRangeValidator );

done_testing();
