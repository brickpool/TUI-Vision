package TUI::Drivers::Display;

use strict;
use warnings;

use Exporter 'import';
our @EXPORT = qw(
  TDisplay
);

use Devel::StrictMode;
use PerlX::Assert::PP;
use Scalar::Util qw( looks_like_number );

use TUI::Drivers::HardwareInfo;

sub TDisplay() { __PACKAGE__ }

my $getCodePage = sub {
  if ( $^O eq 'MSWin32' ) {
    require Win32;
    return Win32::GetConsoleOutputCP();
  }
  return 437;
};

INIT {
  TDisplay->updateIntlChars()
}

sub updateIntlChars {    # void ($class)
  my $class = shift;
  assert ( $class and !ref $class );
  my $cp = &$getCodePage();
  # Some 8-bit code pages are supported directly.
  return 
    if $cp =~ /^(437|720|737|775|850|852|855|857|858|859|860|861|862|863|865)$/
    || $cp =~ /^(866|869)$/;

  require TUI::Views::Frame;
  require TUI::Views::ScrollBar;
  require TUI::Menus::MenuBox;
  require TUI::App::DeskTop;
  if ( $cp == 874 ) {
    $TUI::Views::Frame::frameChars    = "   ' :.+ '\x96+.+++   ' |.+ '\x97+.++ ";
    $TUI::Views::Frame::closeIcon     = "[~x~]";
    $TUI::Views::Frame::zoomIcon      = "[~+~]";
    $TUI::Views::Frame::unZoomIcon    = "[~-~]";
    $TUI::Views::Frame::dragIcon      = "~\x97'~";
    $TUI::Views::ScrollBar::vChars    = "^v # ";
    $TUI::Views::ScrollBar::hChars    = "<> # ";
    $TUI::Menus::MenuBox::frameChars  = " .-.  '-'  | |  +-+ ";
    $TUI::App::DeskTop::defaultBkgrnd = ":";
  }
  elsif ( $cp =~ /^(1250|1251|1252|1253|1254|1256|1257|1258)$/ ) {
    $TUI::Views::Frame::frameChars    = "   ' \xA6.+ '\x96+.+++   ' |.+ '\x97+.+"
                                     . "+ ";
    $TUI::Views::Frame::closeIcon     = "[~\xD7~]";
    $TUI::Views::Frame::zoomIcon      = "[~+~]";
    $TUI::Views::Frame::unZoomIcon    = "[~\xB1~]";
    $TUI::Views::Frame::dragIcon      = "~\x97'~";
    $TUI::Views::ScrollBar::vChars    = "^v \xA4 ";
    $TUI::Views::ScrollBar::hChars    = "<> \xA4 ";
    $TUI::Menus::MenuBox::frameChars  = " .\x97.  '\x97'  | |  +\x97+ ";
    $TUI::App::DeskTop::defaultBkgrnd = ":";
  }
  elsif ( $cp == 1255 ) {
    $TUI::Views::Frame::frameChars    = "   ' :.+ '\x96+.+++   ' |.+ '\x97+.++ ";
    $TUI::Views::Frame::closeIcon     = "[~x~]";
    $TUI::Views::Frame::zoomIcon      = "[~+~]";
    $TUI::Views::Frame::unZoomIcon    = "[~\xB1~]";
    $TUI::Views::Frame::dragIcon      = "~\x97'~";
    $TUI::Views::ScrollBar::vChars    = "^v # ";
    $TUI::Views::ScrollBar::hChars    = "<> # ";
    $TUI::Menus::MenuBox::frameChars  = " .\x97.  '\x97'  | |  +\x97+ ";
    $TUI::App::DeskTop::defaultBkgrnd = ":";
  }
  else {
    $TUI::Views::Frame::frameChars    = "   ' :.+ '-+.+++   ' |.+ '=+.++ ";
    $TUI::Views::Frame::closeIcon     = "[~x~]";
    $TUI::Views::Frame::zoomIcon      = "[~+~]";
    $TUI::Views::Frame::unZoomIcon    = "[~-~]";
    $TUI::Views::Frame::dragIcon      = "~-'~";
    $TUI::Views::ScrollBar::vChars    = "^v # ";
    $TUI::Views::ScrollBar::hChars    = "<> # ";
    $TUI::Menus::MenuBox::frameChars  = " .-.  '-'  | |  +-+ ";
    $TUI::App::DeskTop::defaultBkgrnd = ":";
  }
  return;
} #/ sub updateIntlChars

sub getCursorType {    # $size ($class)
  assert ( $_[0] and !ref $_[0] );
  return THardwareInfo->getCaretSize();
}

sub setCursorType {    # void ($class, $ct)
  my ( $class, $ct ) = @_;
  assert ( $class and !ref $class );
  assert ( looks_like_number $ct );
  THardwareInfo->setCaretSize( $ct & 0xff );
  return;
}

sub clearScreen {    # void ($class, $w, $h)
  my ( $class, $w, $h ) = @_;
  assert ( $class and !ref $class );
  assert ( looks_like_number $w );
  assert ( looks_like_number $h );
  THardwareInfo->clearScreen( $w, $h );
  return;
}

sub getRows {    # $rows ($class)
  assert ( $_[0] and !ref $_[0] );
  return THardwareInfo->getScreenRows();
}

sub getCols {    # $cols ($class)
  assert ( $_[0] and !ref $_[0] );
  return THardwareInfo->getScreenCols();
}

sub getCrtMode {    # void ($class)
  assert ( $_[0] and !ref $_[0] );
  return THardwareInfo->getScreenMode();
}

sub setCrtMode {    # void ($class, $mode)
  my ( $class, $mode ) = @_;
  assert ( $class and !ref $class );
  assert ( looks_like_number $mode );
  THardwareInfo->setScreenMode( $mode );
  return;
}

1
