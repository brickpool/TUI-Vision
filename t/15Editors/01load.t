use strict;
use warnings;

use Test::More;

BEGIN {
  use_ok 'TUI::Objects::Rect';
  use_ok 'TUI::Editors::Const', qw( maxLineLength ); 
  use_ok 'TUI::Editors::Util', qw( countLines );
  use_ok 'TUI::Editors::Indicator';
  use_ok 'TUI::Editors::Editor::Edits';
  use_ok 'TUI::Editors::Editor';
}

isa_ok( TIndicator->new( bounds => TRect->new() ), TIndicator() );

done_testing();
