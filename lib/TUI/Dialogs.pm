package TUI::Dialogs;

use strict;
use warnings;

our $VERSION = '2.000_001';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Import::Into;

use TUI::Dialogs::Const;
use TUI::Dialogs::HistoryViewer::HistList;
use TUI::Dialogs::Util;
use TUI::Dialogs::Button;
use TUI::Dialogs::CheckBoxes;
use TUI::Dialogs::Cluster;
use TUI::Dialogs::Dialog;
use TUI::Dialogs::HistInit;
use TUI::Dialogs::HistoryViewer;
use TUI::Dialogs::HistoryWindow;
use TUI::Dialogs::History;
use TUI::Dialogs::InputLine;
use TUI::Dialogs::Label;
use TUI::Dialogs::ListBox;
use TUI::Dialogs::MultiCheckBoxes;
use TUI::Dialogs::ParamText;
use TUI::Dialogs::RadioButtons;
use TUI::Dialogs::StaticText;
use TUI::Dialogs::StrItem;

sub import {
  my $target = caller;
  TUI::Dialogs::Const->import::into( $target, qw( :all ) );
  TUI::Dialogs::HistoryViewer::HistList->import::into( $target, qw( /\S+/) );
  TUI::Dialogs::Util->import::into( $target, qw( /\S+/) );
  TUI::Dialogs::Button->import::into( $target );
  TUI::Dialogs::CheckBoxes->import::into( $target );
  TUI::Dialogs::Cluster->import::into( $target );
  TUI::Dialogs::Dialog->import::into( $target );
  TUI::Dialogs::HistInit->import::into( $target );
  TUI::Dialogs::HistoryViewer->import::into( $target );
  TUI::Dialogs::HistoryWindow->import::into( $target );
  TUI::Dialogs::History->import::into( $target );
  TUI::Dialogs::InputLine->import::into( $target );
  TUI::Dialogs::Label->import::into( $target );
  TUI::Dialogs::ListBox->import::into( $target );
  TUI::Dialogs::MultiCheckBoxes->import::into( $target );
  TUI::Dialogs::ParamText->import::into( $target );
  TUI::Dialogs::RadioButtons->import::into( $target );
  TUI::Dialogs::StaticText->import::into( $target );
  TUI::Dialogs::StrItem->import::into( $target );
}

sub unimport {
  my $caller = caller;
  TUI::Dialogs::Const->unimport::out_of( $caller );
  TUI::Dialogs::HistoryViewer::HistList::out_of( $caller );
  TUI::Dialogs::Util->unimport::out_of( $caller );
  TUI::Dialogs::Button->unimport::out_of( $caller );
  TUI::Dialogs::CheckBoxes->unimport::out_of( $caller );
  TUI::Dialogs::Cluster->unimport::out_of( $caller );
  TUI::Dialogs::Dialog->unimport::out_of( $caller );
  TUI::Dialogs::HistInit::out_of( $caller );
  TUI::Dialogs::HistoryViewer::out_of( $caller );
  TUI::Dialogs::HistoryWindow::out_of( $caller );
  TUI::Dialogs::History::out_of( $caller );
  TUI::Dialogs::InputLine->unimport::out_of( $caller );
  TUI::Dialogs::Label->unimport::out_of( $caller );
  TUI::Dialogs::ListBox->unimport::out_of( $caller );
  TUI::Dialogs::MultiCheckBoxes->unimport::out_of( $caller );
  TUI::Dialogs::ParamText->unimport::out_of( $caller );
  TUI::Dialogs::RadioButtons->unimport::out_of( $caller );
  TUI::Dialogs::StaticText->unimport::out_of( $caller );
  TUI::Dialogs::StrItem->unimport::out_of( $caller );
}

1
