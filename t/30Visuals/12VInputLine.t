use strict;
use warnings;

use Test::More;
use Storable qw( freeze thaw );
use TUI::Objects::Rect;
use TUI::Dialogs::Button;
use TUI::Dialogs::Const qw( bfNormal );
use TUI::Dialogs::Dialog;
use TUI::Drivers::Const qw( evKeyDown evMouseDown evNothing );
use TUI::Drivers::Event;
use TUI::Drivers::Util qw( getAltCode );
use TUI::Views::Const qw( cmOK ofFirstClick sfDisabled sfSelected );
use TUI::Visuals::InputLine;

my $bounds = new_TRect( 3, 5, 23, 7 );
my $view = new_VInputLine( $bounds, 10, '~N~ame' );

ok( $view->options & ofFirstClick, 'group accepts the first click' );
is_deeply( $view->inputLine->getBounds(), new_TRect( 0, 1, 20, 2 ),
  'input occupies the second row' );
is_deeply( $view->label->getBounds(), new_TRect( 0, 0, 20, 1 ),
  'label occupies the first row' );
is( $view->label->link, $view->inputLine, 'label links to the input' );
is_deeply( $bounds, new_TRect( 3, 5, 23, 7 ), 'bounds are unchanged' );

$view->setData( ['Alice'] );
my @data;
$view->getData( \@data );
is_deeply( \@data, ['Alice'], 'group transfers input data' );

my $copy = thaw( freeze( $view ) );
is( $copy->label->link, $copy->inputLine, 'restored label links to input' );
$copy->getData( \@data );
is_deeply( \@data, ['Alice'], 'restored group retains input data' );

my $dialog = new_TDialog( new_TRect( 0, 0, 40, 14 ), 'Example' );
my $button = new_TButton( new_TRect( 3, 9, 13, 11 ), 'OK', cmOK, bfNormal );
$dialog->setState( sfSelected, 1 );
$dialog->insert( $view );
$dialog->insert( $button );
$button->select();
my $click = TEvent->new( what => evMouseDown, mouse => { where => [4, 5] } );
$dialog->handleEvent( $click );
is( $dialog->current, $view, 'clicking the label selects the input group' );
is( $view->current, $view->inputLine, 'input is selected within the group' );
is( $click->{what}, evNothing, 'label consumes the click' );

my $city = new_VInputLine( new_TRect( 3, 7, 23, 9 ), 10, '~C~ity' );
$dialog->insert( $city );
$view->select();
my $alt_c = TEvent->new(
  what => evKeyDown, keyDown => { keyCode => getAltCode( 'C' ) }
);
$dialog->handleEvent( $alt_c );
is( $dialog->current, $city, 'Alt-C selects the city input group' );
is( $city->current, $city->inputLine, 'city input is selected' );
is( $alt_c->{what}, evNothing, 'city mnemonic is consumed' );

my $alt_n = TEvent->new(
  what => evKeyDown, keyDown => { keyCode => getAltCode( 'N' ) }
);
$dialog->handleEvent( $alt_n );
is( $dialog->current, $view, 'Alt-N selects the name input group' );
is( $alt_n->{what}, evNothing, 'name mnemonic is consumed' );

my $key = TEvent->new( what => evKeyDown, keyDown => { keyCode => ord 'x' } );
$dialog->handleEvent( $key );
isnt( $view->inputLine->data, 'Alice', 'ordinary key reaches active input' );
is( $city->inputLine->data, '', 'ordinary key does not reach inactive input' );

$city->setState( sfDisabled, 1 );
$alt_c = TEvent->new(
  what => evKeyDown, keyDown => { keyCode => getAltCode( 'C' ) }
);
$dialog->handleEvent( $alt_c );
is( $dialog->current, $view, 'disabled input group is not selected' );
is( $alt_c->{what}, evKeyDown, 'disabled group does not consume mnemonic' );

$button->select();
$alt_n = TEvent->new(
  what => evKeyDown, keyDown => { keyCode => getAltCode( 'N' ) }
);
$dialog->handleEvent( $alt_n );
is( $dialog->current, $view, 'Alt-N selects input from a button' );
is( $alt_n->{what}, evNothing, 'mnemonic from button is consumed' );

done_testing();
