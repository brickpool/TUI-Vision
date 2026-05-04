package TUI::Drivers;

use strict;
use warnings;

our $VERSION = '2.000_001';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Import::Into;

use TUI::Drivers::Const;
use TUI::Drivers::HardwareInfo;
use TUI::Drivers::Display;
use TUI::Drivers::Screen;
use TUI::Drivers::SystemError;
use TUI::Drivers::Event;
use TUI::Drivers::HWMouse;
use TUI::Drivers::Mouse;
use TUI::Drivers::EventQueue;
use TUI::Drivers::Util;

sub import {
  my $target = caller;
  TUI::Drivers::Const->import::into( $target, qw( :all ) );
  TUI::Drivers::HardwareInfo->import::into( $target );
  TUI::Drivers::Display->import::into( $target );
  TUI::Drivers::Screen->import::into( $target );
  TUI::Drivers::SystemError->import::into( $target );
  TUI::Drivers::Event->import::into( $target );
  TUI::Drivers::HWMouse->import::into( $target );
  TUI::Drivers::Mouse->import::into( $target );
  TUI::Drivers::EventQueue->import::into( $target );
  TUI::Drivers::Util->import::into( $target, qw( /\S+/ ) );
}

sub unimport {
  my $caller = caller;
  TUI::Drivers::Const->unimport::out_of( $caller );
  TUI::Drivers::HardwareInfo->unimport::out_of( $caller );
  TUI::Drivers::Display->unimport::out_of( $caller );
  TUI::Drivers::Screen->unimport::out_of( $caller );
  TUI::Drivers::SystemError->unimport::out_of( $caller );
  TUI::Drivers::Event->unimport::out_of( $caller );
  TUI::Drivers::HWMouse->unimport::out_of( $caller );
  TUI::Drivers::Mouse->unimport::out_of( $caller );
  TUI::Drivers::EventQueue->unimport::out_of( $caller );
  TUI::Drivers::Util->unimport::out_of( $caller );
}

1
