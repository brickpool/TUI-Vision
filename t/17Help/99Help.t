use strict;
use warnings;

use Test::More;

BEGIN {
  use_ok 'TUI::Help';
}

isa_ok( new_TRefTable( 10, 5 ), TRefTable() );
isa_ok( new_THelpIndex(), THelpIndex() );
isa_ok( new_THelpTopic(), THelpTopic() );
isa_ok( new_TTopicDefinition( 'Introduction', 100 ), TTopicDefinition() );

done_testing();
