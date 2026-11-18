use strict;
use warnings;

use Test::More;

BEGIN {
  use_ok 'TUI::Help::RefTable';
  use_ok 'TUI::Help::HelpBase';
  use_ok 'TUI::Help::HelpIndex';
  use_ok 'TUI::Help::TopicDefinition';
}

isa_ok( TRefTable->new( limit => 10, delta => 5 ), TRefTable() );
isa_ok( THelpIndex->new(), THelpIndex() );
isa_ok( TTopicDefinition->new( topic => 'Introduction', value => 100 ),
  TTopicDefinition() );
done_testing();
