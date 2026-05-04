package TUI::TextView;

use strict;
use warnings;

our $VERSION = '2.000_001';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Import::Into;

use TUI::TextView::TextDevice;
use TUI::TextView::Terminal;

sub import {
  my $target = caller;
  TUI::TextView::TextDevice->import::into( $target );
  TUI::TextView::Terminal->import::into( $target );
}

sub unimport {
  my $caller = caller;
  TUI::TextView::TextDevice->unimport::out_of( $caller );
  TUI::TextView::Terminal->unimport::out_of( $caller );
}

1
