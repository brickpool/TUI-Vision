use strict;
use warnings;

use Test::More;

BEGIN {
  use_ok 'TUI::Common';
}

ok( defined &INT_MAX, 'INT_MAX imported' );
is( $TUI::Dialogs::RadioButtons::button, ' ( ) ',
  'common loads the shared text globals' );

done_testing();
