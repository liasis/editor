/**
 * \file PLEditorViewController.h
 * \brief Liasis Python IDE text editor view controller implementation file.
 *
 * \details
 * This file contains the function prototypes and interface for a view
 * controller subclass. This class controls a set of views tha make up the text
 * editor capabilities of the python IDE.
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
 * \author Danny Nicklas.
 * \author Jason Lomnitz.
 * \date 2012-2014.
 *
 * \todo Add a custom text storage/ NSLayoutManager that works with 
 *       textEditorView to generate syntax highlighting, autocompletion, etc.
 *
 * \todo Optimize line scan and line numbering algorithm for more efficient line
 *       numbering.
 */

#import <Cocoa/Cocoa.h>
#import <LiasisKit/LiasisKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PLTextEditorView.h"
#import "PLGotoLineWindowController.h"

/**
 * \class PLEditorViewController \headerfile \headerfile
 * \brief A NSViewController subclass that controls the view of the Liasis Text
 *        Editor view extension.
 *
 * \details The PLEditorViewController manages all properties and behaviors of
 *          Liasis Text Editor view extension. It is a delegate of its
 *          NSTextView instance variable and includes a NSScrollView of the 
 *          document along with a status bar with the number of lines in the
 *          document.
 *
 *          The class maintains a PLLineNumberView for displaying the line
 *          numbers, a PLThemeManager to provide text coloring for the document,
 *          a PLSyntaxHighlighter for syntax coloring, and a PLFormatter for
 *          automatic indendtation and tab cycling. PLEditorViewController also
 *          includes a means to turn line wrap on or off.
 *
 *          The PLEditorViewController prompts the user before closing an
 *          unsaved document. It manages returning "Untitled" for the name of
 *          unsaved files or the name of the saved file, otherwise. It includes
 *          an asterisk next to the name to notify the user that the file has
 *          unsaved changes.
 */
@interface PLEditorViewController : NSViewController <NSTextViewDelegate, NSTextStorageDelegate, PLAddOnExtension, PLNavigationDataSource, PLNavigationDelegate> {
        /**
         * \brief NSTextView representing the document text view.
         */
        IBOutlet PLTextEditorView <PLThemeable> * textEditorView;

        /**
         * \brief NSScrollView representing the document scroll view.
         */
        IBOutlet NSScrollView * scrollView;
        
        /**
         * \brief NSTextField that displays the number of lines in the text
         *        editor view in the status bar.
         */
        IBOutlet NSTextField * numberOfLinesField;
        
        /**
         * \brief The status bar text field.
         */
        IBOutlet NSTextField * statusText;
        
        /**
         * \brief The popup button containing a list of code navigation
         *        selections.
         */
        IBOutlet PLNavigationPopUpButton * navigationPopUpButton;
        
        /**
         * \brief The line number ruler view.
         */
        PLLineNumberView * lineNumberView;
        
        /**
         * \brief The syntax highlighter controlling how text elements are
         *        colored.
         */
        PLSyntaxHighlighter * syntaxHighlighter;
        
        /**
         * \brief The formatter controlling automatic indentation and tab
         *        cycling.
         */
        PLFormatter * formatter;
        
        /**
         * \brief The parser controlling parsing information from python files.
         */
        id <PLAddOnPluginIntrospection> pythonIntrospectionController;
        
        /**
         * \brief The view controller managing the autocomplete system.
         */
        PLAutocompleteViewController * autocompleteViewController;
        
        /**
         * \brief The NSURL linking to the open file of the document.
         */
        NSURL * fileUrl;
        
        /**
         * \brief A BOOL representing if the document is saved or unsaved.
         */
        BOOL isUnsaved;
        
        PLTextDocument * textDocument;        


        IBOutlet NSImageView * lockedImage;
        
        /**
         * \brief The timer used for code introspection.
         */
        NSTimer * parseTimer;
        
        /**
         * \brief The timer used to underline variables in the text.
         */
        NSTimer * underliningTimer;
        
        /**
         * \brief The dictionary of possible completions mapped to their index
         *        in the text.
         *
         * \details Maintain this dictionary as a fallback in case the parse
         *          fails due to invalid syntax.
         */
        NSDictionary * autocompleteVariables;
        
        /**
         * \brief The dictionary for the navigation pop up button.
         *
         * \details Map ranges of navigation items (stored as NSValues) to
         *          their name.
         */
        NSDictionary * navigationDictionary;
        
        /**
         * \brief The controller for the goto line window controller.
         */
        PLGotoLineWindowController * gotoLineWindowController;
}

#pragma mark Properties

@property(retain) PLSyntaxHighlighter * syntaxHighlighter;

/**
 * \brief The location of the vertical column ruler in number of characters.
 *
 * \details Setting the ruler calculates its x position as the padding offset of
 *          the text container + column location * the character width. The
 *          character width is the maximumAdvancement of the font.
 */
@property(assign, nonatomic) NSUInteger columnRuler;

#pragma mark Document Property Management

/**
 * \brief Set if line wrap is on or off.
 *
 * \details If setting line wrap on, text wraps to the window. If off, the text
 *          continues outside the window. This is done by setting the
 *          bounds of the NSTextContainer object of the NSTextView.
 *
 * \param aBool The boolean specifying if line wrap is on or off.
 */
-(void)setLineWrap:(BOOL)aBool;

/**
 * \brief Update the theme manager.
 *
 * \details Update the properties (e.g. background and text color) of the text
 *          view and line number view.
 */
-(void)updateThemeManager;

#pragma mark Add On Extension Protocol

/**
 * \brief Add on extension factory method.
 * 
 * \details The method is called by the tab view controller when a PLPEditor
 *          is created by the tab view controller, or any view controller in 
 *          general. The method loads the PLEditorViewController.nib file,
 *          that must be found within the resources of its encapsulating 
 *          bundle.
 *
 * \return An instance of the PLEditorViewController initialized with the
 *         corresponding nib file in the view extension's resource directory.
 */
+(id)viewController;

/**
 * \brief Return the addon type.
 *
 * \return PLAddOnExtension.
 */
+(PLAddOnType)type;

#pragma mark Tab Subviews

/**
 * \brief Return the tab subview name.
 *
 * \return "Text Editor".
 */
+(NSString *)tabSubviewName;

/**
 * \brief Determine if the tab subview should close depending on save state.
 *
 * \details If the view is unsaved, prompt the user to save it before closing.
 *
 * \param sender The sender.
 *
 * \return A boolean specifying if the tab view should close.
 */
-(BOOL)tabSubviewShouldClose:(id)sender;

#pragma mark Save/Load File

/**
 * \brief Save a file with the current name.
 *
 * \details Save the file if it is linked to an open file, otherwise present
 *          the Save As dialog window.
 *
 * \param sender The action sender.
 *
 * \return An IBAction response.
 */
-(IBAction)saveFile:(id)sender;

/**
 * \brief Save As a file with a new name and directory.
 *
 * \details Present the user the save dialog window and store the new file URL.
 *
 * \param sender The action sender.
 *
 * \return An IBAction response.
 */
-(IBAction)saveFileAs:(id)sender;

#pragma mark Navigation Data Source

/**
 * \brief Delegate method to return an array of navigation ranges.
 *
 * \details Return the keys of the navigationDictionary instance variable.
 *
 * \param navigationPopUpButton The navigation popup button sending the message.
 *
 * \return An array of NSValue objects encapsulating navigation ranges.
 */
-(NSArray *)rangesForNavigationPopUpButton:(PLNavigationPopUpButton *)navigationPopUpButton;

/**
 * \brief Delegate method to return the title of a navigation range.
 *
 * \details Return the title of the PLNavigationItem value for the range key in
 *          the navigationDictionary instance variable.
 *
 * \param navigationPopUpButton The navigation popup button sending the message.
 *
 * \param range The navigation range.
 *
 * \return A string representing the title of the navigation range.
 */
-(NSString *)navigationPopUpButton:(PLNavigationPopUpButton *)navigationPopUpButton titleForRange:(NSRange)range;

/**
 * \brief Delegate method to return the title of a navigation range.
 *
 * \details Return the image of the PLNavigationItem value for the range key in
 *          the navigationDictionary instance variable.
 *
 * \param navigationPopUpButton The navigation popup button sending the message.
 *
 * \param range The navigation range.
 *
 * \return An image for the navigation range.
 */
-(NSImage *)navigationPopUpButton:(PLNavigationPopUpButton *)navigationPopUpButton imageForRange:(NSRange)range;


@end
