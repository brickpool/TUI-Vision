package TUI::Gadgets;

use strict;
use warnings;

our $VERSION = '2.000_001';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Import::Into;

use TUI::Gadgets::Const;
use TUI::Gadgets::PrintConstants;
use TUI::Gadgets::ClockView;
use TUI::Gadgets::EventViewer;
use TUI::Gadgets::HeapView;

sub import {
  my $target = caller;
  TUI::Gadgets::Const->import::into( $target, qw( :all ) );
  TUI::Gadgets::PrintConstants->import::into( $target );
  TUI::Gadgets::ClockView->import::into( $target );
  TUI::Gadgets::EventViewer->import::into( $target );
  TUI::Gadgets::HeapView->import::into( $target );
}

sub unimport {
  my $caller = caller;
  TUI::Gadgets::Const->unimport::out_of( $caller );
  TUI::Gadgets::PrintConstants->unimport::out_of( $caller );
  TUI::Gadgets::ClockView->unimport::out_of( $caller );
  TUI::Gadgets::EventViewer->unimport::out_of( $caller );
  TUI::Gadgets::HeapView->unimport::out_of( $caller );
}

1
