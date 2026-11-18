use strict;
use warnings;

use Test::More;

BEGIN {
  use_ok 'TUI::Help::RefTable';
  use_ok 'TUI::Help::HelpBase';
  use_ok 'TUI::Help::HelpIndex';
}

isa_ok( TRefTable->new( limit => 10, delta => 5 ), TRefTable() );
isa_ok( THelpIndex->new(), THelpIndex() );
done_testing();
