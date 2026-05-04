package TUI::Drivers::Mouse;

use strict;
use warnings;

use Exporter 'import';
our @EXPORT = qw(
  TMouse
);

use TUI::Drivers::HWMouse;

sub TMouse() { __PACKAGE__ }

use parent THWMouse;

1
