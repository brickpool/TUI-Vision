package TUI::StdDlg;

use strict;
use warnings;

our $VERSION = '2.000_001';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Import::Into;

use TUI::StdDlg::Const;
use TUI::StdDlg::ChDirDialog;
use TUI::StdDlg::Dir;
use TUI::StdDlg::DirCollection;
use TUI::StdDlg::DirEntry;
use TUI::StdDlg::DirListBox;
use TUI::StdDlg::Dos;
use TUI::StdDlg::Util;
use TUI::StdDlg::FileCollection;
use TUI::StdDlg::FileDialog;
use TUI::StdDlg::FileInfoPane;
use TUI::StdDlg::FileInputLine;
use TUI::StdDlg::FileList;
use TUI::StdDlg::SortedListBox;

sub import {
  my $target = caller;
  TUI::StdDlg::Const->import::into( $target, qw( :all ) );
  TUI::StdDlg::Dos->import::into( $target, qw( /\S+/ ) );
  TUI::StdDlg::Dir->import::into( $target, qw( /\S+/ ) );
  TUI::StdDlg::Util->import::into( $target, qw( /\S+/ ) );
  TUI::StdDlg::ChDirDialog->import::into( $target );
  TUI::StdDlg::DirCollection->import::into( $target );
  TUI::StdDlg::DirEntry->import::into( $target );
  TUI::StdDlg::DirListBox->import::into( $target );
  TUI::StdDlg::FileCollection->import::into( $target );
  TUI::StdDlg::FileDialog->import::into( $target );
  TUI::StdDlg::FileInfoPane->import::into( $target );
  TUI::StdDlg::FileInputLine->import::into( $target );
  TUI::StdDlg::FileList->import::into( $target );
  TUI::StdDlg::SortedListBox->import::into( $target );
}

sub unimport {
  my $caller = caller;
  TUI::StdDlg::Const->unimport::out_of( $caller );
  TUI::StdDlg::Dos->unimport::out_of( $caller );
  TUI::StdDlg::Dir->unimport::out_of( $caller );
  TUI::StdDlg::Util->unimport::out_of( $caller );
  TUI::StdDlg::ChDirDialog->unimport::out_of( $caller );
  TUI::StdDlg::DirCollection->unimport::out_of( $caller );
  TUI::StdDlg::DirEntry->unimport::out_of( $caller );
  TUI::StdDlg::DirListBox->unimport::out_of( $caller );
  TUI::StdDlg::FileCollection->unimport::out_of( $caller );
  TUI::StdDlg::FileDialog->unimport::out_of( $caller );
  TUI::StdDlg::FileInfoPane->unimport::out_of( $caller );
  TUI::StdDlg::FileInputLine->unimport::out_of( $caller );
  TUI::StdDlg::FileList->unimport::out_of( $caller );
  TUI::StdDlg::SortedListBox->unimport::out_of( $caller );
}

1
