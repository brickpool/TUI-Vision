package TUI::StdDlg::DirCollection;
# ABSTRACT: A collection of directory entries

use 5.010;
use strict;
use warnings;

our $VERSION = '2.000_001';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Exporter 'import';
our @EXPORT = qw(
  TDirCollection
  new_TDirCollection
);

use TUI::toolkit;

use TUI::Objects::NSCollection;
use TUI::Objects::Collection;

sub TDirCollection() { __PACKAGE__ }
sub name() { 'TDirCollection' };
sub new_TDirCollection { __PACKAGE__->from(@_) }

extends TCollection;

sub at {    # $dirEntry|undef ($index)
  goto &TUI::Objects::NSCollection::at;
}

sub indexOf {    # $index ($item|undef)
  goto &TUI::Objects::NSCollection::indexOf;
}

sub remove {    # void ($item)
  goto &TUI::Objects::NSCollection::remove;
}

sub free {    # void ($item)
  goto &TUI::Objects::NSCollection::free;
}

sub atInsert {    # void ($index, $item|undef)
  goto &TUI::Objects::NSCollection::atInsert;
}

sub atPut {    # void ($index, $item|undef)
  goto &TUI::Objects::NSCollection::atInsert;
}

sub insert {    # $index ($item|undef)
  goto &TUI::Objects::NSCollection::insert;
}

sub firstThat {    # $dirEntry|undef (\&Test, $arg|undef)
  goto &TUI::Objects::NSCollection::firstThat;
}

sub lastThat {    # $dirEntry|undef (\&Test, $arg|undef)
  goto &TUI::Objects::NSCollection::lastThat;
}

1
