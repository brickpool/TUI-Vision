package TUI::Views;

use strict;
use warnings;

our $VERSION = '2.000_001';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Import::Into;

use TUI::Views::Const;
use TUI::Views::CommandSet;
use TUI::Views::DrawBuffer;
use TUI::Views::Palette;
use TUI::Views::View;
use TUI::Views::Group;
use TUI::Views::Frame;
use TUI::Views::ListViewer;
use TUI::Views::ScrollBar;
use TUI::Views::WindowInit;
use TUI::Views::Window;
use TUI::Views::Util;

sub import {
  my $target = caller;
  TUI::Views::Const->import::into( $target, qw( :all ) );
  TUI::Views::CommandSet->import::into( $target );
  TUI::Views::DrawBuffer->import::into( $target );
  TUI::Views::Palette->import::into( $target );
  TUI::Views::View->import::into( $target );
  TUI::Views::Group->import::into( $target );
  TUI::Views::Frame->import::into( $target );
  TUI::Views::ListViewer->import::into( $target );
  TUI::Views::ScrollBar->import::into( $target );
  TUI::Views::WindowInit->import::into( $target );
  TUI::Views::Window->import::into( $target );
  TUI::Views::Util->import::into( $target, qw( message ) );
}

sub unimport {
  my $caller = caller;
  TUI::Views::Const->unimport::out_of( $caller );
  TUI::Views::CommandSet->unimport::out_of( $caller );
  TUI::Views::DrawBuffer->unimport::out_of( $caller );
  TUI::Views::Palette->unimport::out_of( $caller );
  TUI::Views::View->unimport::out_of( $caller );
  TUI::Views::Group->unimport::out_of( $caller );
  TUI::Views::Frame->unimport::out_of( $caller );
  TUI::Views::ListViewer->unimport::out_of( $caller );
  TUI::Views::ScrollBar->unimport::out_of( $caller );
  TUI::Views::WindowInit->unimport::out_of( $caller );
  TUI::Views::Window->unimport::out_of( $caller );
  TUI::Views::Util->unimport::out_of( $caller );
}

1
