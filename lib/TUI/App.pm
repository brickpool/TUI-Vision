package TUI::App;

use strict;
use warnings;

our $VERSION = '2.000_001';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Import::Into;

use TUI::App::Const;
use TUI::App::Background;
use TUI::App::DeskInit;
use TUI::App::DeskTop;
use TUI::App::ProgInit;
use TUI::App::Program;
use TUI::App::Application;

sub import {
  my $target = caller;
  TUI::App::Const->import::into( $target, qw( :all ) );
  TUI::App::Background->import::into( $target );
  TUI::App::DeskInit->import::into( $target );
  TUI::App::DeskTop->import::into( $target );
  TUI::App::ProgInit->import::into( $target );
  TUI::App::Program->import::into( $target, qw ( /\S+/ ) );
  TUI::App::Application->import::into( $target );
}

sub unimport {
  my $caller = caller;
  TUI::App::Const->unimport::out_of( $caller );
  TUI::App::Background->unimport::out_of( $caller );
  TUI::App::DeskInit->unimport::out_of( $caller );
  TUI::App::DeskTop->unimport::out_of( $caller );
  TUI::App::ProgInit->unimport::out_of( $caller );
  TUI::App::Program->unimport::out_of( $caller );
  TUI::App::Application->unimport::out_of( $caller );
}

1
