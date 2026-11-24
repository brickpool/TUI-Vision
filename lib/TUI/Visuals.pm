package TUI::Visuals;
# ABSTRACT: Visual components for TUI::Vision

use 5.010;
use strict;
use warnings;

our $VERSION = '2.000003';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Import::Into;

use TUI::Visuals::Button;
use TUI::Visuals::InputLine;

sub import {
  my $target = caller;
  TUI::Visuals::Button->import::into( $target );
  TUI::Visuals::InputLine->import::into( $target );
}

sub unimport {
  my $caller = caller;
  TUI::Visuals::Button->unimport::out_of( $caller );
  TUI::Visuals::InputLine->unimport::out_of( $caller );
}

1;
