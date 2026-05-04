package TUI::Memory;

use strict;
use warnings;

our $VERSION = '2.000_001';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Import::Into;

use TUI::Memory::Util;

sub import {
  my $target = caller;
  TUI::Memory::Util->import::into( $target, qw( lowMemory ) );
}

sub unimport {
  my $caller = caller;
  TUI::Memory::Util->unimport::out_of( $caller );
}

1
