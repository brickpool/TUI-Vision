use strict;
use warnings;

use Test::More;
use TUI::Common::Text;

our ( $radio_before_load, $months_before_load, $indicator_before_load );
our $title_after_load;
BEGIN {
  $radio_before_load = $TUI::Dialogs::RadioButtons::button;
  $months_before_load = $TUI::StdDlg::FileInfoPane::months;
  $indicator_before_load = $TUI::Editors::Indicator::dragFrame;
  local $TUI::Help::HelpWindow::helpWinTitle = 'Assistance';
  require TUI::Help::HelpWindow;
  $title_after_load = $TUI::Help::HelpWindow::helpWinTitle;
}

subtest 'text globals are initialized before their modules load' => sub {
  is( $radio_before_load, ' ( ) ', 'radio button text is available' );
  is_deeply( $months_before_load,
    [ '', qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec ) ],
    'month names are available' );
  is( $indicator_before_load, "\xCD", 'indicator character is in CP437' );
};

subtest 'loading an owning module preserves a customized value' => sub {
  is( $title_after_load, 'Assistance',
    'the module does not reinitialize its text' );
};

done_testing();
