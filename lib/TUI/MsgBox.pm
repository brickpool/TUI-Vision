package TUI::MsgBox;

use strict;
use warnings;

our $VERSION = '2.000_001';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Import::Into;

use TUI::MsgBox::Const;
use TUI::MsgBox::MsgBoxText;

sub import {
  my $target = caller;
  TUI::MsgBox::Const->import::into( $target, qw( :all ) );
  TUI::MsgBox::MsgBoxText->import::into( $target, qw( /^messageBox|inputBox/ ) );
}

sub unimport {
  my $caller = caller;
  TUI::MsgBox::Const->unimport::out_of( $caller );
  TUI::MsgBox::MsgBoxText->unimport::out_of( $caller );
}

1
