/**
 * \file PLGotoLineWindowController.h
 * \brief Liasis Python IDE window controller for the Go To Line window.
 *
 * \details This file contains the interface for the Go To Line window
 *          controller.
 *
 * \copyright Copyright (C) 2012-2014 Jason Lomnitz and Danny Nicklas.
 *
 * This file is part of the Python Liasis IDE.
 *
 * The Python Liasis IDE is free software: you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * The Python Liasis IDE is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with the Python Liasis IDE. If not, see <http://www.gnu.org/licenses/>.
 *
 * \author Jason Lomnitz.
 * \author Danny Nicklas.
 * \date 2012-2014.
 */

#import <Cocoa/Cocoa.h>

/**
 * \class PLGotoLineWindowController \headerfile \headerfile
 * \brief A NSWindowController subclass that controls the Go To Line window.
 *
 * \details The window includes a text field that allows the user to specify a
 *          line and (optionally) column to jump to. The text field is parsed
 *          for "line:column" and returns the selected line number and column to
 *          the object that prompted the window through a block callback
 */
@interface PLGotoLineWindowController : NSWindowController <NSWindowDelegate>
{
        /**
         * \brief The text field to enter line number and column.
         */
        IBOutlet NSTextField * textField;
        
        /**
         * \brief The button to perform the jump.
         */
        IBOutlet NSButton * goButton;
        
        /**
         * \brief The button to cancel the jump.
         */
        IBOutlet NSButton * cancelButton;
        
        /**
         * \brief The block callback used to allow the object to respond to an
         *        input.
         */
        void (^gotoHandler)(NSUInteger lineNumber, NSUInteger column);
}

/**
 * \brief Factory method to return a new window controller.
 *
 * \details Instantiates the controller through the initWithWindowNibName:
 *          NSWindowController method.
 *
 * \return A window controller on the autorelease pool.
 */
+(instancetype)gotoLineWindowController;

/**
 * \brief Primary method to show the window.
 *
 * \details This method shows the window with the input lineNumber and column as
 *          defaults filled in (providing the user a hint for how to enter a new
 *          line number and column). The block is called when the user selects
 *          the Go button allowing the object that sent this message to respond.
 *          This method loads the window from the nib if it is not already done.
 *
 *          Important note: line numbers and columns are indexed from 1, not 0.
 *
 * \param lineNumber The line number displayed in the text field on appearance.
 *
 * \param column The column displayed in the text field on appearance.
 *
 * \param handler The block called when the user selects the Go button.
 *
 *      \param gotoLine The line number that the user entered.
 *
 *      \param gotoColumn The column that the user entered. This will be 1 if
 *                        user did not enter a column.
 */
-(void)showWindowWithLineNumber:(NSUInteger)lineNumber column:(NSUInteger)column gotoHandler:(void (^)(NSUInteger gotoLine, NSUInteger gotoColumn))handler;

@end
