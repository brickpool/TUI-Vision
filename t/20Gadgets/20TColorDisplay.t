use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN {
  use_ok 'TUI::Objects::Rect';
  use_ok 'TUI::Drivers::Const', qw( evBroadcast );
  use_ok 'TUI::Drivers::Event';
  use_ok 'TUI::Drivers::ColorAttr';
  use_ok 'TUI::Gadgets::Const', qw( :cmXXXX );
  use_ok 'TUI::Gadgets::ColorDisplay';
}

{
  package MyColorDisplay;

  use TUI::toolkit;
  extends 'TUI::Gadgets::ColorDisplay';

  sub drawView  { ::pass 'drawView()' }
  sub writeLine { ::pass 'writeLine()' }

  $INC{'MyColorDisplay.pm'} = 1;
}

my $view;
subtest 'TColorDisplay->new()' => sub {
  require_ok 'MyColorDisplay';
  $view = MyColorDisplay->new(
    bounds => TRect->new(),
    text   => 'Color'
  );
  isa_ok( $view, TColorDisplay );
  is( $view->{text}, 'Color', 'text initialized' );
  isa_ok( $view->{color}, TColorAttr );
};

subtest 'draw()' => sub {
  can_ok( $view, 'draw' );
  lives_ok { $view->draw() } 'draw() does not die';
};

subtest 'setColor()' => sub {
  can_ok( $view, 'setColor' );
  my $attr = TColorAttr->new( bios => 0x1E );
  lives_ok { $view->setColor( $attr ) } 'setColor() does not die';
  is( $view->{color}->asBIOS, 0x1E, 'color updated' );
};

subtest 'handleEvent() foreground' => sub {
  can_ok( $view, 'handleEvent' );
  $view->{color} = TColorAttr->new( bios => 0x17 );
  my $event = TEvent->new(
    what    => evBroadcast,
    message => {
      command  => cmColorForegroundChanged,
      infoByte => 0x0A,
    },
  );
  lives_ok { $view->handleEvent( $event ) } 'foreground event does not die';
  is( $view->{color}->asBIOS, 0x1A, 'foreground changed' );
};

subtest 'handleEvent() background' => sub {
  $view->{color} = TColorAttr->new( bios => 0x17 );
  my $event = TEvent->new(
    what    => evBroadcast,
    message => {
      command  => cmColorBackgroundChanged,
      infoByte => 0x03,
    },
  );
  lives_ok { $view->handleEvent( $event ) } 'background event does not die';
  is( $view->{color}->asBIOS, 0x37, 'background changed' );
};

done_testing();
