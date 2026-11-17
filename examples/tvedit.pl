#---------------------------------------------------------#
#                                                         #
#   Turbo Vision TVEDIT Source File                       #
#                                                         #
#---------------------------------------------------------#
#
#      Turbo Vision - Version 2.0 (Perl Edition)
#
#      Copyright (c) 1994 by Borland International
#      All Rights Reserved.
#
#
package TEditorApp;

use TUI::Objects;
use TUI::Menus;
use TUI::Drivers;
use TUI::App;
use TUI::Views;
use TUI::Dialogs;
use TUI::MsgBox;
use TUI::StdDlg;
use TUI::Editors;

use TUI::toolkit;

sub ::new_TEditorApp { __PACKAGE__->new( argc => shift, argv => shift ) }

extends TApplication;

use constant cmChangeDrct => 102;

sub BUILDARGS {
  my ( $class, %args ) = ( shift, @_ );
  return {
    %{ $class->SUPER::BUILDARGS() },
    argc   => $args{argc} // 0,
    argv   => $args{argv} // [],
    bounds => new_TRect( 0, 0, 80, 25 ),
  };
}

sub BUILD {
  my ( $self, $args ) = @_;

  my $ts = new_TCommandSet();
  $ts->enableCmd( $_ ) for (
    cmSave, 
    cmSaveAs, 
    cmCut, 
    cmCopy, 
    cmPaste, 
    cmClear, 
    cmUndo,
    cmFind, 
    cmReplace, 
    cmSearchAgain,
  );
  $self->disableCommands( $ts );

  $TUI::Editors::Editor::editorDialog = \&doEditDialog;

  my $argv = $args->{argv};
  my $argc = $args->{argc};
  while (--$argc > 0) {                           # Open files specified
    $self->openEditor( $argv->[$argc], true );    # on command line.
  }
  $deskTop->cascade( $deskTop->getExtent() );

  # Create a hidden clipboard editor window for internal use
  my $clipWindow = new_TEditWindow( $deskTop->getExtent(), undef, wnNoNumber );
  $clipWindow->hide();
  $deskTop->insert( $clipWindow );
  $TUI::Editors::Editor::clipboard = $clipWindow->{editor};

  return;
}

sub openEditor {
  my ( $self, $fileName, $visible ) = @_;
  my $r = $deskTop->getExtent();
  my $p = $self->validView( new_TEditWindow( $r, $fileName, wnNoNumber ) );
  if ( $p ) {
    $p->hide() if !$visible;
    $deskTop->insert( $p );
  }
  return $p;
}

sub fileOpen {
  my ( $self ) = @_;
  my @fileName = ('*.*');
  if ( $self->executeDialog(
    new_TFileDialog( '*.*', 'Open file', '~N~ame', fdOpenButton, 100 ),
    \@fileName,
  ) != cmCancel ) {
    $self->openEditor( $fileName[0], true );
  }
  return;
}

sub fileNew {
  my ( $self ) = @_;
  $self->openEditor( undef, true );
  return;
}

sub changeDir {
  my ( $self ) = @_;
  $self->executeDialog( new_TChDirDialog( cdNormal, 0 ), undef );
  return;
}

sub handleEvent {
  my ( $self, $event ) = @_;
  $self->SUPER::handleEvent( $event );

  if ( $event->{what} == evCommand ) {
    SWITCH: for ( $event->{message}{command} ) {

      cmOpen == $_ and do {
        $self->fileOpen();
        last;
      };

      cmNew == $_ and do {
        $self->fileNew();
        last;
      };

      cmChangeDrct == $_ and do {
        $self->changeDir();
        last;
      };

      DEFAULT: {
        return;
      }
    } #/ SWITCH: for ( $event->{message}...)
    $self->clearEvent( $event );
  } #/ if ( $event->{what} ==...)
  return;
} #/ sub handleEvent

sub createFindDialog {
  my $d = new_TDialog( new_TRect( 0, 0, 38, 12 ), "Find" );

  $d->{options} |= ofCentered;

  my $control = new_TInputLine( new_TRect( 3, 3, 32, 4 ), 80 );
  $d->insert( $control );
  $d->insert(
    new_TLabel( new_TRect( 2, 2, 15, 3 ), "~T~ext to find", $control ) );
  $d->insert(
    new_THistory( new_TRect( 32, 3, 35, 4 ), $control, 10 ) );

  $d->insert( new_TCheckBoxes( new_TRect( 3, 5, 35, 7 ),
    new_TSItem( "~C~ase sensitive",
    new_TSItem( "~W~hole words only", undef ))));

  $d->insert(
    new_TButton( new_TRect( 14, 9, 24, 11 ), "O~K~", cmOK, bfDefault ) );
  $d->insert(
    new_TButton( new_TRect( 26, 9, 36, 11 ), "Cancel", cmCancel, bfNormal ) );

  $d->selectNext( !!0 );
  return $d;
}

sub createReplaceDialog {
  my $d = new_TDialog( new_TRect( 0, 0, 40, 16 ), "Replace" );

  $d->{options} |= ofCentered;

  my $control = new_TInputLine( new_TRect( 3, 3, 34, 4 ), 80 );
  $d->insert( $control );
  $d->insert(
    new_TLabel( new_TRect( 2, 2, 15, 3 ), "~T~ext to find", $control ) );
  $d->insert( new_THistory( new_TRect( 34, 3, 37, 4 ), $control, 10 ) );

  $control = new_TInputLine( new_TRect( 3, 6, 34, 7 ), 80 );
  $d->insert( $control );
  $d->insert(
    new_TLabel( new_TRect( 2, 5, 12, 6 ), "~N~ew text", $control ) );
  $d->insert( new_THistory( new_TRect( 34, 6, 37, 7 ), $control, 11 ) );

  $d->insert( new_TCheckBoxes( new_TRect( 3, 8, 37, 12 ),
    new_TSItem( "~C~ase sensitive",
    new_TSItem( "~W~hole words only",
    new_TSItem( "~P~rompt on replace",
    new_TSItem( "~R~eplace all", undef ))))));

  $d->insert(
    new_TButton( new_TRect( 17, 13, 27, 15 ), "O~K~", cmOK, bfDefault ) );
  $d->insert( new_TButton( new_TRect( 28, 13, 38, 15 ),
    "Cancel", cmCancel, bfNormal ) );

  $d->selectNext( false );
  return $d;
}

sub initMenuBar {
  my ( $class, $r ) = @_;
  
  my $sub1 =
    new_TSubMenu( "~F~ile", kbAltF ) +
      new_TMenuItem( "~O~pen", cmOpen, kbF3, hcNoContext, "F3" ) +
      new_TMenuItem( "~N~ew", cmNew, kbCtrlN, hcNoContext, "Ctrl-N" ) +
      new_TMenuItem( "~S~ave", cmSave, kbF2, hcNoContext, "F2" ) +
      new_TMenuItem( "S~a~ve as...", cmSaveAs, kbNoKey ) +
      newLine() +
      new_TMenuItem( "~C~hange dir...", cmChangeDrct, kbNoKey ) +
      new_TMenuItem( "E~x~it", cmQuit, kbCtrlQ, hcNoContext, "Ctrl-Q" );

  my $sub2 =
    new_TSubMenu( "~E~dit", kbAltE ) +
      new_TMenuItem( "~U~ndo", cmUndo, kbCtrlU, hcNoContext, "Ctrl-U" ) +
      newLine() +
      new_TMenuItem( "Cu~t~", cmCut, kbShiftDel, hcNoContext, "Shift-Del" ) +
      new_TMenuItem( "~C~opy", cmCopy, kbCtrlIns, hcNoContext, "Ctrl-Ins" ) +
      new_TMenuItem( "~P~aste", cmPaste, kbShiftIns, hcNoContext,
        "Shift-Ins" ) +
      newLine() +
      new_TMenuItem( "~C~lear", cmClear, kbCtrlDel, hcNoContext, "Ctrl-Del" );

  my $sub3 =
    new_TSubMenu( "~S~earch", kbAltS ) +
      new_TMenuItem( "~F~ind...", cmFind, kbNoKey ) +
      new_TMenuItem( "~R~eplace...", cmReplace, kbNoKey ) +
      new_TMenuItem( "~S~earch again", cmSearchAgain, kbNoKey );

  my $sub4 =
    new_TSubMenu( "~W~indows", kbAltW ) +
      new_TMenuItem( "~S~ize/move", cmResize, kbCtrlF5, hcNoContext,
        "Ctrl-F5" ) +
      new_TMenuItem( "~Z~oom", cmZoom, kbF5, hcNoContext, "F5" ) +
      new_TMenuItem( "~N~ext", cmNext, kbF6, hcNoContext, "F6" ) +
      new_TMenuItem( "~P~revious", cmPrev, kbShiftF6, hcNoContext,
        "Shift-F6" ) +
      new_TMenuItem( "~C~lose", cmClose, kbCtrlW, hcNoContext, "Ctrl+W" );

  $r->{b}{y} = $r->{a}{y} + 1;
  return new_TMenuBar( $r, $sub1 + $sub2 + $sub3 + $sub4 );
}

sub initStatusLine {
  my ( $class, $r ) = @_;
  $r->{a}{y} = $r->{b}{y} - 1;
  return new_TStatusLine( $r,
    new_TStatusDef( 0, 0xFFFF ) +
      new_TStatusItem( '', kbAltX, cmQuit ) +
      new_TStatusItem( "~F2~ Save", kbF2, cmSave ) +
      new_TStatusItem( "~F3~ Open", kbF3, cmOpen ) +
      new_TStatusItem( "~Ctrl-W~ Close", kbAltF3, cmClose ) +
      new_TStatusItem( "~F5~ Zoom", kbF5, cmZoom ) +
      new_TStatusItem( "~F6~ Next", kbF6, cmNext ) +
      new_TStatusItem( "~F10~ Menu", kbF10, cmMenu ) +
      new_TStatusItem( '', kbShiftDel, cmCut ) +
      new_TStatusItem( '', kbCtrlIns, cmCopy ) +
      new_TStatusItem( '', kbShiftIns, cmPaste ) +
      new_TStatusItem( '', kbCtrlF5, cmResize )
  );
}

sub outOfMemory {
  messageBox( "Not enough memory for this operation.", mfError | mfOKButton );
  return;
}

sub doEditDialog {
  my ( $dialog, $arg ) = @_;
  SWITCH: for ( $dialog ) {

    edOutOfMemory == $_ and do {
      return messageBox( "Not enough memory for this operation",
        mfError | mfOKButton );
    };

    edReadError == $_ and do {
      return messageBox( "Error reading file $arg.", mfError | mfOKButton );
    };

    edWriteError == $_ and do {
      return messageBox( "Error writing file $arg.", mfError | mfOKButton );
    };

    edCreateError == $_ and do {
      return messageBox( "Error creating file $arg.", mfError | mfOKButton );
    };

    edSaveModify == $_ and do {
      return messageBox( "$arg has been modified. Save?",
        mfInformation | mfYesNoCancel );
    };

    edSaveUntitled == $_ and do {
      return messageBox( "Save untitled file?",
        mfInformation | mfYesNoCancel );
    };

    edSaveAs == $_ and do {
      my @fileName = ( $_[1] );
      my $res = $application->executeDialog(
        new_TFileDialog( '*.*', 'Save file as', '~N~ame', fdOKButton, 101 ),
        \@fileName,
      );
      $_[1] = shift @fileName if $res != cmCancel;
      return $res;
    };

    edFind == $_ and do {
      return $application->executeDialog( createFindDialog(), $arg );
    };

    edSearchFailed == $_ and do {
      return messageBox( "Search string not found.", mfError | mfOKButton );
    };

    edReplace == $_ and do {
      return $application->executeDialog( createReplaceDialog(), $arg );
    };

    edReplacePrompt == $_ and do {
      # Avoid placing the dialog on the same line as the cursor
      my $r = new_TRect( 0, 1, 40, 8 );
      $r->move( int( ( $deskTop->{size}{x} - $r->{b}{x} ) / 2 ), 0 );
      my $t = $deskTop->makeGlobal( $r->{b} );
      $t->{y}++;
      my $pt = $arg;
      if ( $pt->{y} <= $t->{y} ) {
        $r->move( 0, $deskTop->{size}{y} - $r->{b}{y} - 2 );
      }
      return messageBoxRect( $r, "Replace this occurence?",
        mfYesNoCancel | mfInformation );
    };

  }
  return cmCancel;
}

package main; 

sub main {
  my ( $argc, $argv ) = @_;
  my $editorApp = new_TEditorApp( $argc, $argv );
  $editorApp->run();
  $editorApp->shutDown();
  return 0;
}

exit main( @ARGV+1, [ $0, @ARGV ] );
