#---------------------------------------------------------#
#                                                         #
#   Turbo Vision Shadow Demo Source File                  #
#                                                         #
#---------------------------------------------------------#
#
#   Turbo Vision - Version 2.0 (Perl Edition)
#
#   Copyright (c) 1990-1994, 1997 by Borland International
#   All Rights Reserved.
#
#   Based on SHADOW.PAS (Turbo Pascal 6.0, Turbo Vision).
#   Copyright (c) 1991 by tewi Verlag GmbH
#
package TShadowApp;

use strict;
use warnings;

use TUI::Objects;
use TUI::Menus;
use TUI::Drivers;
use TUI::App;
use TUI::Views;
use TUI::Dialogs;

use TUI::toolkit;

sub ::new_TShadowApp { __PACKAGE__->new() }

extends TApplication;

our ( $shadowAttr, $shadowSize );
*shadowAttr = \$TUI::Views::View::shadowAttr;
*shadowSize = \$TUI::Views::View::shadowSize;

use constant {
  cmShadowDialog => 112,
};

{
  package TShadowDialog;

  use strict;
  use warnings;

  use TUI::Objects;
  use TUI::Drivers;
  use TUI::App;
  use TUI::Validate;
  use TUI::Views;
  use TUI::Dialogs;

  use TUI::toolkit;

  extends TDialog;

  use constant {
    cmRedraw => 113,
  };

  # Data record in the order the controls are visited by TShadowDialog::getData.
  use Class::Struct DataRec => [
    attr => '$',
    x    => '$',
    y    => '$',
  ];

  sub BUILDARGS {
    return shift->SUPER::BUILDARGS( 
      bounds => new_TRect( 22, 4, 54, 16 ), 
      title  => 'Shadow Dialog',
    );
  }

  sub BUILD {
    my $self = shift;
    my $r = TRect->new();

    # Pascal's TNumInputLine is a TInputLine with a range validator here.
    # 255 needs three digits, so the attribute field uses maxLen 3.
    $r->assign( 16, 3, 20, 4 );
    my $attr = new_TInputLine( $r, 3, new_TRangeValidator( 0, 255 ) );
    $self->insert( $attr );

    $r->assign( 3, 3, 15, 4 );
    $self->insert( new_TLabel( $r, 'Shadow Attr', $attr ) );

    $r->assign( 16, 5, 20, 6 );
    my $x = new_TInputLine( $r, 2, new_TRangeValidator( 0, 20 ) );
    $self->insert( $x );

    $r->assign( 3, 5, 15, 6 );
    $self->insert( new_TLabel( $r, 'Shadow Size', $x ) );

    $r->assign( 23, 5, 27, 6 );
    my $y = new_TInputLine( $r, 2, new_TRangeValidator( 0, 20 ) );
    $self->insert( $y );

    $r->assign( 20, 5, 22, 6 );
    $self->insert( new_TLabel( $r, ':', $y ) );

    $r->assign( 9, 8, 22, 10 );
    $self->insert( new_TButton( $r, 'Draw View', cmRedraw, bfDefault ) );

    $self->selectNext( false );
    return;
  }

  sub handleEvent {
    my ( $self, $event ) = @_;
    $self->SUPER::handleEvent( $event );
    if ( $event->{what} == evCommand ) {
      if ( $event->{message}{command} == cmRedraw ) {
        if ( $self->valid( cmRedraw ) ) {
          my $dataRec = DataRec->new();
          $self->getData( $dataRec );
          $shadowAttr      = int $dataRec->attr;
          $shadowSize->{x} = int $dataRec->x;
          $shadowSize->{y} = int $dataRec->y;
          $deskTop->redraw();
        }
        $self->clearEvent( $event );
      }
    }
    return;
  }
}

sub BUILDARGS {
  return {
    %{ shift->SUPER::BUILDARGS() },
    bounds => new_TRect( 0, 0, 80, 25 ),
  };
}

sub shadowDialog {
  my $self = shift;
  my $dlg = TShadowDialog->new();
  my $dataRec = DataRec->new(
    attr => 0+ $shadowAttr,
    x    => $shadowSize->{x},
    y    => $shadowSize->{y},
  );
  $dlg->setData( $dataRec );
  $deskTop->execView( $dlg );
  return;
}

sub handleEvent {
  my ( $self, $event ) = @_;
  $self->SUPER::handleEvent( $event );
  if ( $event->{what} == evCommand ) {
    if ( $event->{message}{command} == cmShadowDialog ) {
      $self->shadowDialog();
      $self->clearEvent( $event );
    }
  }
  return;
}

sub initMenuBar {
  my ( $class, $r ) = @_;
  $r->{b}{y} = $r->{a}{y} + 1;
  return new_TMenuBar( $r,
    new_TSubMenu( "~F~ile", kbAltF )
      + new_TMenuItem( "~S~hadow Dialog", cmShadowDialog, kbF7, hcNoContext, 
        "F7" )
      + newLine()
      + new_TMenuItem( "E~x~it", cmQuit, kbAltX, hcNoContext, "Alt-X" )
  );
}

sub initStatusLine {
  my ( $class, $r ) = @_;
  $r->{a}{y} = $r->{b}{y} - 1;
  return new_TStatusLine( $r,
    new_TStatusDef( 0, 0xFFFF )
      + new_TStatusItem( "~Alt-X~ Exit", kbAltX, cmQuit )
      + new_TStatusItem( "~F10~ Menu",   kbF10,  cmMenu )
  );
}

package main;

sub main {
  my $shadowApp = new_TShadowApp();
  $shadowApp->run();
  return 0;
}

exit main( @ARGV+1, [ $0, @ARGV ] );
