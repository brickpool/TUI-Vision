use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN {
  use_ok 'TUI::Visuals::Button';
  use_ok 'TUI::Objects::Rect';
  use_ok 'TUI::Dialogs::Button';
  use_ok 'TUI::Dialogs::Const';
  use_ok 'TUI::Drivers::Const', qw( :evXXXX );
  use_ok 'TUI::Drivers::Event';
  use_ok 'TUI::Views::Const', qw( :sfXXXX );
  use_ok 'TUI::Views::Group';
  use_ok 'TUI::Visuals::Button';
}

{
  package ButtonEventGroup;
  use TUI::toolkit;
  extends 'TUI::Views::Group';

  our ( @incoming, @posted );
  sub getEvent {
    my ( $self, $event ) = @_;
    die 'No mouse event queued' unless @incoming;
    $event->assign( shift @incoming );
  }
  sub putEvent {
    my ( $self, $event ) = @_;
    push @posted, $event->clone();
  }
}

my $button = new_VButton(
  TRect->new( ax => 0, ay => 0, bx => 12, by => 3 ),
  '~O~K', 300, bfDefault,
);

my $standard = new_TButton(
  TRect->new( ax => 0, ay => 0, bx => 12, by => 3 ),
  '~O~K', 300, bfDefault,
);
is_deeply( $button->getPalette(), $standard->getPalette(),
  'uses the standard button palette' );

lives_ok { $button->draw() } 'draws a raised button';
lives_ok { $button->drawState( 1 ) } 'draws a pressed button';

$button->setState( sfFocused, 1 );
lives_ok { $button->draw() } 'draws a focused button';

$button->setState( sfDisabled, 1 );
lives_ok { $button->draw() } 'draws a disabled button';

subtest 'single-line mouse click' => sub {
  my $group = ButtonEventGroup->new(
    bounds => TRect->new( ax => 0, ay => 0, bx => 20, by => 5 ),
  );
  my $view = VButton->new(
    bounds  => TRect->new( ax => 0, ay => 0, bx => 10, by => 1 ),
    title   => '~O~K',
    command => 300,
    flags   => 0,
  );
  $group->insert( $view );

  @ButtonEventGroup::incoming = (
    TEvent->new( what => evMouseUp, mouse => { where => [ 4, 0 ] } ),
  );
  @ButtonEventGroup::posted = ();
  my $event = TEvent->new(
    what => evMouseDown, mouse => { where => [ 4, 0 ] },
  );
  $view->handleEvent( $event );
  is( $event->{what}, evNothing, 'mouse click is consumed' );
  is( $ButtonEventGroup::posted[0]{message}{command}, 300,
    'mouse click posts the button command' );
};

done_testing();
