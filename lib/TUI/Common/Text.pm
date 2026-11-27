package TUI::Common::Text;
# ABSTRACT: Turbo Vision text globals.

use 5.010;
use strict;
use warnings;

our $VERSION = '2.000003';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

no warnings 'once';

# We use the UnitedStates code page (cp437)

# TVTEXT1.CPP
$TUI::Views::View::specialChars =
  [ "\xAF", "\xAE", "\x1A", "\x1B", ' ', ' ' ];
  # cp437: "»«→←  "

$TUI::Dialogs::RadioButtons::button = " ( ) ";

$TUI::Menus::MenuBox::frameChars =
  " \xDA\xC4\xBF  \xC0\xC4\xD9  \xB3 \xB3  \xC3\xC4\xB4 ";
  # cp437: " ┌─┐  └─┘  │ │  ├─┤ "

$TUI::Views::Frame::initFrame =
  "\x06\x0A\x0C\x05\x00\x05\x03\x0A\x09\x16\x1A\x1C\x15\x00\x15\x13\x1A\x19";

$TUI::Views::Frame::frameChars =
  "   \xC0 \xB3\xDA\xC3 \xD9\xC4\xC1\xBF\xB4\xC2\xC5".
  "   \xC8 \xBA\xC9\xC7 \xBC\xCD\xCF\xBB\xB6\xD1 ";
  # cp437: "   └ │┌├ ┘─┴┐┤┬┼"
  #        "   ╚ ║╔╟ ╝═╧╗╢╤ "

$TUI::Views::Frame::closeIcon  = "[~\xFE~]";      # cp437: "[~■~]"
$TUI::Views::Frame::zoomIcon   = "[~\x18~]";      # cp437: "[~↑~]"
$TUI::Views::Frame::unZoomIcon = "[~\x12~]";      # cp437: "[~↕~]"
$TUI::Views::Frame::dragIcon   = "~\xC4\xD9~";    # cp437: "~─┘~"

$TUI::Editors::Indicator::dragFrame   = "\xCD";    # cp437: "═"
$TUI::Editors::Indicator::normalFrame = "\xC4";    # cp437: "─"

$TUI::Dialogs::History::icon = "\xDE~\x19~\xDD";    # cp437: "▐~↓~▌"

$TUI::ColorSel::ColorSelector::icon = "\xDB";    # cp437: "█"

$TUI::ColorSel::MonoSelector::button    = " ( ) ";
$TUI::ColorSel::MonoSelector::normal    = "Normal";
$TUI::ColorSel::MonoSelector::highlight = "Highlight";
$TUI::ColorSel::MonoSelector::underline = "Underline";
$TUI::ColorSel::MonoSelector::inverse   = "Inverse";

$TUI::ColorSel::ColorDialog::colors     = "Colors";
$TUI::ColorSel::ColorDialog::groupText  = "~G~roup";
$TUI::ColorSel::ColorDialog::itemText   = "~I~tem";
$TUI::ColorSel::ColorDialog::forText    = "~F~oreground";
$TUI::ColorSel::ColorDialog::bakText    = "~B~ackground";
$TUI::ColorSel::ColorDialog::textText   = "Text ";
$TUI::ColorSel::ColorDialog::colorText  = "Color";
$TUI::ColorSel::ColorDialog::okText     = "O~K~";
$TUI::ColorSel::ColorDialog::cancelText = "Cancel";

$TUI::Dialogs::InputLine::rightArrow = "\x10";    # cp437: "►"
$TUI::Dialogs::InputLine::leftArrow  = "\x11";    # cp437: "◄"

$TUI::Menus::StatusLine::hintSeparator = "\xB3 "; # cp437: "│ "

$TUI::Dialogs::CheckBoxes::button = " [ ] ";

$TUI::Views::ScrollBar::vChars = "\x1E\x1F\xB1\xFE\xB2";    # cp437: "▲▼░■▒"
$TUI::Views::ScrollBar::hChars = "\x11\x10\xB1\xFE\xB2";    # cp437: "◄►░■▒"

$TUI::Dialogs::Button::shadows = "\xDC\xDB\xDF";    # cp437: "▄█▀"
$TUI::Dialogs::Button::markers = "[]";

$TUI::StdDlg::DirListBox::pathDir   = "\xC0\xC4\xC2";    # cp437: "└─┬"
$TUI::StdDlg::DirListBox::firstDir  = "\xC0\xC2\xC4";    # cp437: "└┬─"
$TUI::StdDlg::DirListBox::middleDir = " \xC3\xC4";       # cp437: " ├─"
$TUI::StdDlg::DirListBox::lastDir   = " \xC0\xC4";       # cp437: " └─"
$TUI::StdDlg::DirListBox::drives    = "Drives";
$TUI::StdDlg::DirListBox::graphics  = "\xC0\xC3\xC4";    # cp437: "└├─"

$TUI::Editors::FileEditor::backupExt = '.BAK';

# TVTEXT2.CPP
$TUI::Validate::PXPictureValidator::errorMsg = "Error in picture format.\n %s";
$TUI::Validate::FilterValidator::errorMsg    = "Invalid character in input";
$TUI::Validate::RangeValidator::errorMsg = "Value not in the range %d to %d";
$TUI::Validate::StringLookupValidator::errorMsg =
	"Input is not in list of valid strings";

$TUI::Validate::RangeValidator::validUnsignedChars = "+0123456789";
$TUI::Validate::RangeValidator::validSignedChars   = "+-0123456789";

$TUI::Views::ListViewer::emptyText = "<empty>";

$TUI::Help::HelpWindow::helpWinTitle = 'Help';
$TUI::Help::HelpFile::invalidContext = "\n No help available in this context.";

$TUI::Editors::EditWindow::clipboardTitle = 'Clipboard';
$TUI::Editors::EditWindow::untitled       = 'Untitled';

$TUI::StdDlg::FileList::tooManyFiles = "Too many files.";

$TUI::App::Program::exitText = "~Alt-X~ Exit";

$TUI::MsgBox::MsgBoxText::yesText         = "~Y~es";
$TUI::MsgBox::MsgBoxText::noText          = "~N~o";
$TUI::MsgBox::MsgBoxText::okText          = "O~K~";
$TUI::MsgBox::MsgBoxText::cancelText      = "Cancel";
$TUI::MsgBox::MsgBoxText::warningText     = "Warning";
$TUI::MsgBox::MsgBoxText::errorText       = "Error";
$TUI::MsgBox::MsgBoxText::informationText = "Information";
$TUI::MsgBox::MsgBoxText::confirmText     = "Confirm";

$TUI::StdDlg::ChDirDialog::changeDirTitle = "Change Directory";
$TUI::StdDlg::ChDirDialog::dirNameText    = "Directory ~n~ame";
$TUI::StdDlg::ChDirDialog::dirTreeText    = "Directory ~t~ree";
$TUI::StdDlg::ChDirDialog::okText         = "O~K~";
$TUI::StdDlg::ChDirDialog::chdirText      = "~C~hdir";
$TUI::StdDlg::ChDirDialog::revertText     = "~R~evert";
$TUI::StdDlg::ChDirDialog::helpText       = "Help";
$TUI::StdDlg::ChDirDialog::drivesText     = "Drives";
$TUI::StdDlg::ChDirDialog::invalidText    = "Invalid directory";

$TUI::StdDlg::FileDialog::filesText        = "~F~iles";
$TUI::StdDlg::FileDialog::openText         = "~O~pen";
$TUI::StdDlg::FileDialog::okText           = "O~K~";
$TUI::StdDlg::FileDialog::replaceText      = "~R~eplace";
$TUI::StdDlg::FileDialog::clearText        = "~C~lear";
$TUI::StdDlg::FileDialog::cancelText       = "Cancel";
$TUI::StdDlg::FileDialog::helpText         = "~H~elp";
$TUI::StdDlg::FileDialog::invalidDriveText = "Invalid drive or directory";
$TUI::StdDlg::FileDialog::invalidFileText  = "Invalid file name.";

$TUI::StdDlg::FileInfoPane::pmText = "p";
$TUI::StdDlg::FileInfoPane::amText = "a";
$TUI::StdDlg::FileInfoPane::months = [ '', qw(
  Jan Feb Mar Apr May Jun
  Jul Aug Sep Oct Nov Dec
)];

$TUI::App::DeskTop::defaultBkgrnd = "\xB0";    # cp437: "░"

$TUI::Drivers::SystemError::errorString = [
  "Disk in drive %c is write protected",
  "Unknown unit %c",
  "Disk is not ready in drive %c",
  "Critical error (unknown command) on drive %c",
  "Data integrity error on drive %c",
  "Critical error (bad request) on drive %c",
  "Seek error on drive %c",
  "Unknown media type in drive %c",
  "Sector not found on drive %c",
  "Printer out of paper",
  "Write fault on drive %c",
  "Read fault on drive %c",
  "General failure on drive %c",
  "Sharing violation on drive %c",
  "Lock violation on drive %c",
  "Disk change invalid on drive %c",
  "FCB unavailable",
  "Sharing buffer overflow",
  "Code page mismatch",
  "Out of input",
  "Insufficient disk space on drive %c",
  "Insert diskette in drive %c",
];

$TUI::Drivers::SystemError::sRetryOrCancel = "~Enter~ Retry  ~Esc~ Cancel";

1;

__END__

=head1 NAME

TUI::Common::Text - shared Turbo Vision text resources

=head1 SYNOPSIS

  use TUI::Common::Text;

  $TUI::Help::HelpWindow::helpWinTitle = 'Assistance';

=head1 DESCRIPTION

C<TUI::Common::Text> initializes shared text and character resources in
their respective packages. The variables are accessed by their fully
qualified names and are not exported. Some character resources use CP437
byte values.

For the global variables, see L<TUI::Manual::Reference::Globals>.

=head1 SEE ALSO

L<TUI::Common>, L<TUI::Manual::Reference::Globals>

=head1 AUTHORS

=over

=item * Borland International (original Turbo Vision design)

=item * J. Schneider <brickpool@cpan.org> (Perl implementation and maintenance)

=back

=head1 CONTRIBUTORS

=over

=item * Eric Woodruff

=back

=head1 COPYRIGHT AND LICENSE

Copyright (c) 1990-1994, 1997 by Borland International

Copyright (c) 1995, 2026 the L</AUTHORS> and L</CONTRIBUTORS> as listed above.

This software is licensed under the MIT license (see the LICENSE file, which is
part of the distribution).

=cut
