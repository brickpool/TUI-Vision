use strict;
use warnings;

use TUI::App;
use TUI::Dialogs;
use TUI::MsgBox;
use TUI::Objects;
use TUI::Views;
use TUI::Visuals;

my $app = new_TApplication();
my $dialog = new_TDialog(
  new_TRect( 18, 4, 60, 18 ), 'VInputLine Demo'
);

$dialog->insert(
  new_VInputLine( new_TRect( 3, 2, 39, 4 ), 30, '~N~ame' )
);
$dialog->insert(
  new_VInputLine( new_TRect( 3, 5, 39, 7 ), 30, '~C~ity' )
);
$dialog->insert(
  new_VButton( new_TRect( 9, 10, 19, 13 ), '~O~K', cmOK, bfDefault )
);
$dialog->insert(
  new_VButton( new_TRect( 23, 10, 33, 13 ), 'Cancel', cmCancel, bfNormal )
);

my $data = [ 'Alice', 'Berlin' ];
if ( $app->executeDialog( $dialog, $data ) == cmOK ) {
  messageBox(
    "Name: $data->[0]\nCity: $data->[1]",
    mfInformation | mfOKButton,
  );
}
