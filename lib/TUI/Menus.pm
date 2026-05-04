package TUI::Menus;

use strict;
use warnings;

our $VERSION = '2.000_001';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Import::Into;

use TUI::Menus::Const;
use TUI::Menus::Menu;
use TUI::Menus::MenuItem;
use TUI::Menus::SubMenu;
use TUI::Menus::MenuView;
use TUI::Menus::MenuBar;
use TUI::Menus::MenuBox;
use TUI::Menus::StatusItem;
use TUI::Menus::StatusDef;
use TUI::Menus::StatusLine;

sub import {
  my $target = caller;
  TUI::Menus::Const->import::into( $target, qw( :all ) );
  TUI::Menus::Menu->import::into( $target );
  TUI::Menus::MenuItem->import::into( $target );
  TUI::Menus::SubMenu->import::into( $target );
  TUI::Menus::MenuView->import::into( $target );
  TUI::Menus::MenuBar->import::into( $target );
  TUI::Menus::MenuBox->import::into( $target );
  TUI::Menus::StatusItem->import::into( $target );
  TUI::Menus::StatusDef->import::into( $target );
  TUI::Menus::StatusLine->import::into( $target );
}

sub unimport {
  my $caller = caller;
  TUI::Menus::Const->unimport::out_of( $caller );
  TUI::Menus::Menu->unimport::out_of( $caller );
  TUI::Menus::MenuItem->unimport::out_of( $caller );
  TUI::Menus::SubMenu->unimport::out_of( $caller );
  TUI::Menus::MenuView->unimport::out_of( $caller );
  TUI::Menus::MenuBar->unimport::out_of( $caller );
  TUI::Menus::MenuBox->unimport::out_of( $caller );
  TUI::Menus::StatusItem->unimport::out_of( $caller );
  TUI::Menus::StatusDef->unimport::out_of( $caller );
  TUI::Menus::StatusLine->unimport::out_of( $caller );
}

1;
