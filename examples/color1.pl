#========================================================================
# The following example routines have been provided by the Technical
# Support staff at Borland International. They are provided as a
# courtesy and not as part of a Borland product, and as such, are
# provided without the assurance of technical support or any specific
# guarantees.
#========================================================================
# Turbo Vision - Modifying the desktop pattern
#
# This sample code demonstrates one method of modifying the desktop
# to change the desktop pattern.
#
# The TApplication::initDeskTop function is used to initialize the
# desktop. This is defined by the object returned by initDeskTop.
# In order to change the pattern of the desktop, you must do the
# following:
#   1. Derive a class from TDeskTop which modifies the default
#      desktop. The initBackground function of your derived class
#      returns a TBackground object which is initialized with a
#      character which determines the background pattern.
#   2. Redefine the initDeskTop function in the class that you
#      derive from TApplication to return an object of your new
#      desktop class.
# Additionally, in order to modify the desktop colors, you need to
# do the following:
#   3. Derive a new TBackground object in which you redefine the
#      getPalette function to return your desired palette.
#   4. Modify the initDeskTop function mentioned in step 2 to return
#      the new TBackground object you have defined.
#------------------------------------------------------------------------
#
#      Copyright (c) 1991 by Borland International
#      All Rights Reserved.
#
#
use 5.010;
use strict;
use warnings;

use TUI::Objects;
use TUI::App;
use TUI::Drivers;
use TUI::Menus;
use TUI::Views;
use TUI::Dialogs;
use TUI::toolkit;

#========================================================================
# Global data
#------------------------------------------------------------------------
use constant {
  cmAbout      => 100,       # User selected menu item 'About'
  cpNewDeskTop => "\x13",    # Palette used by the new desktop
  PATTERN      => 225,       # Character used for the background pattern
};

#========================================================================
# Class definitions
#------------------------------------------------------------------------
{
  package TSampleProgram;
  use TUI::toolkit;
  extends ::TApplication;

  # Main application class.
  # The inherited default status line is used.
  sub initMenuBar;
  sub initDeskTop;
  sub handleEvent;
  sub aboutDialog;
}

{
  package TNewDeskTop;
  # we derive a new desk top which will instantiate the background
  # object with the character we select for the pattern
  # also, the initBackground function is overridden to return
  # our specialized TNewBackground

  use TUI::toolkit;
  extends ::TDeskTop;

  # This desktop creates the background object with the selected
  # pattern and the specialized background palette.
  sub initBackground;
}

{
  package TNewBackground;
  # we derive a new background for to return our
  # specified palette

  use TUI::toolkit;
  extends ::TBackground;

  # This background returns the palette specified for this example.
  sub getPalette;
}

#========================================================================
# Implementation of TSampleProgram
#------------------------------------------------------------------------

# Define the menu bar.
sub TSampleProgram::initMenuBar {
  my ( $class, $bounds ) = @_;
  $bounds->{b}{y} = $bounds->{a}{y} + 1;
  return new_TMenuBar( $bounds,
    new_TMenu( new_TMenuItem( '~A~bout', cmAbout, kbAltA, hcNoContext ) )
  );
}

# Redefine desktop initialization to use the new desktop.
sub TSampleProgram::initDeskTop {
  my ( $class, $bounds ) = @_;

  # initDeskTop is passed the rectangle for the application's window,
  # which in this case is the whole screen.
  $bounds->{a}{y}++;
  $bounds->{b}{y}--;
  return TNewDeskTop->new( bounds => $bounds );
}

# Override the event handler so it can display the About box.
sub TSampleProgram::handleEvent {
  package TSampleProgram;
  my ( $self, $event ) = @_;
  $self->SUPER::handleEvent( $event );

  if ( $event->{what} == ::evCommand ) {
    SWITCH: for ( $event->{message}{command} ) {
      ::cmAbout == $_ and do {
        $self->aboutDialog();
        $self->clearEvent( $event );
        last;
      };
    } #/ SWITCH: for ( $event->{message}{command} )
  }
  return;
}

# Create the modal About dialog box.
sub TSampleProgram::aboutDialog {
  my ( $self ) = @_;
  my $dialog = new_TDialog( new_TRect( 0, 0, 35, 12 ), 'About' );
  $dialog->{options} |= ofCentered;

  $dialog->insert(
    new_TStaticText( new_TRect( 1, 2, 34, 7 ),
      "\003Turbo Vision Example\n\003\n" .
      "\003Modifying the desktop\n\003\n" .
      "\003Borland Technical Support"
    )
  );
  $dialog->insert(
    new_TButton( new_TRect( 3, 9, 32, 11 ), '~O~k', cmOK, bfDefault )
  );

  $self->executeDialog( $dialog );
  return;
}

#========================================================================
# Implementation of TNewDeskTop
#------------------------------------------------------------------------

# Initialize the background using the selected pattern and palette.
sub TNewDeskTop::initBackground {
  my ( $self, $bounds ) = @_;
  return TNewBackground->new(
    bounds  => $bounds,
    pattern => chr( PATTERN ),
  );
}

#========================================================================
# Implementation of TNewBackground
#------------------------------------------------------------------------

# Return the palette for this background.
sub TNewBackground::getPalette {
  state $palette = TPalette->new(
    data => cpNewDeskTop,
    size => length( cpNewDeskTop ),
  );
  return $palette->clone();
}

#========================================================================
package main;

# Start the application.
my $sampleProgram = TSampleProgram->new();
$sampleProgram->run();
exit;
