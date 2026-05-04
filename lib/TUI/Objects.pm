package TUI::Objects;

use strict;
use warnings;

our $VERSION = '2.000_001';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Import::Into;

use TUI::Objects::Const;
use TUI::Objects::Object;
use TUI::Objects::Point;
use TUI::Objects::Rect;
use TUI::Objects::NSCollection;
use TUI::Objects::NSSortedCollection;
use TUI::Objects::Collection;
use TUI::Objects::SortedCollection;
use TUI::Objects::StringCollection;

sub import {
  my $target = caller;
  TUI::Objects::Const->import::into( $target, qw( :all ) );
  TUI::Objects::Object->import::into( $target );
  TUI::Objects::Point->import::into( $target );
  TUI::Objects::Rect->import::into( $target );
  TUI::Objects::NSCollection->import::into( $target );
  TUI::Objects::NSSortedCollection->import::into( $target );
  TUI::Objects::Collection->import::into( $target );
  TUI::Objects::SortedCollection->import::into( $target );
  TUI::Objects::StringCollection->import::into( $target );
}

sub unimport {
  my $caller = caller;
  TUI::Objects::Const->unimport::out_of( $caller );
  TUI::Objects::Object->unimport::out_of( $caller );
  TUI::Objects::Point->unimport::out_of( $caller );
  TUI::Objects::Rect->unimport::out_of( $caller );
  TUI::Objects::NSCollection->unimport::out_of( $caller );
  TUI::Objects::NSSortedCollection->unimport::out_of( $caller );
  TUI::Objects::Collection->unimport::out_of( $caller );
  TUI::Objects::SortedCollection->unimport::out_of( $caller );
  TUI::Objects::StringCollection->unimport::out_of( $caller );
}

1
