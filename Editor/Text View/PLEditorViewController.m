/**
 * \file PLEditorViewController.m
 * \brief Liasis Python IDE text editor view controller implementation file.
 *
 * \details
 * This file contains the public and private methods and interface for a view
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
 * \author Jason Lomnitz.
 * \author Danny Nicklas.
 * \date 2012-2014.
 */

#import "PLEditorViewController.h"

#pragma mark Utility Functions (Prototypes)

/**
 * \brief Return the line number for a character position.
 *
 * \details Iterate over all lines in the string until reaching the string that
 *          contains the desired position. Note that line numbers begin at 1,
 *          rather than 0.
 *
 * \param string The string to search in.
 *
 * \param position The character position to find the line number within.
 *
 * \return The line number for a given character position.
 */
NSUInteger lineNumberForPosition(NSString * string, NSUInteger position);

/**
 * \brief Return the starting position in a string for a line number.
 *
 * \details Iterate over all lines in the string until reaching the line number,
 *          incrementing the character position by line ranges.
 *
 * \param string The string to search in.
 *
 * \param position The line number to find the starting position of.
 *
 * \return The line number for a given character position.
 */
NSUInteger positionForLineNumber(NSString * string, NSUInteger lineNumber);

#pragma mark Utility Functions (Implementation)

NSUInteger lineNumberForPosition(NSString * string, NSUInteger position)
{
        NSUInteger numberOfLines = 0, index = 0;
        NSRange lineRange;

        for (index = 0, numberOfLines = 1; index < [string length]; numberOfLines++) {
                lineRange = [string lineRangeForRange:NSMakeRange(index, 0)];
                if (NSLocationInRange(position, lineRange))
                        break;
                index = NSMaxRange(lineRange);
        }

        /* Edge case where position is at end of string and not preceded by a newline character */
        if (position == [string length] && [string lineRangeForRange:NSMakeRange(index, 0)].length > 0)
                numberOfLines--;

        return numberOfLines;
}

NSUInteger positionForLineNumber(NSString * string, NSUInteger lineNumber)
{
        NSUInteger numberOfLines = 0, index = 0;
        
        for (index = 0, numberOfLines = 1; index < [string length]; numberOfLines++) {
                if (numberOfLines == lineNumber)
                        break;
                index = NSMaxRange([string lineRangeForRange:NSMakeRange(index, 0)]);
        }
        return index;
}

@implementation PLEditorViewController

@synthesize syntaxHighlighter;

-(void)setColumnRuler:(NSUInteger)columnRuler
{
        NSUInteger rulerLocation = 0;
        NSFont * font = nil;
        CGFloat fontWidth = 0.0f;
        
        _columnRuler = columnRuler;
        font = [[NSFontManager sharedFontManager] selectedFont];
        fontWidth = [font maximumAdvancement].width;
        rulerLocation = [[textEditorView textContainer] lineFragmentPadding] + fontWidth * _columnRuler;
        [textEditorView setColumnRuler:rulerLocation];
}

-(void)setLineWrap:(BOOL)aBool
{
        NSSize contentSize = [scrollView contentSize];
        [textEditorView setMinSize:contentSize];
        NSTextContainer *textContainer = [textEditorView textContainer];
        
        if (aBool) {
                [textContainer setContainerSize:NSMakeSize(contentSize.width, CGFLOAT_MAX)];
                [textContainer setWidthTracksTextView: YES];
                [textEditorView setHorizontallyResizable: NO];
                
        } else {
                [textContainer setContainerSize:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX)];
                [textContainer setWidthTracksTextView: NO];
                [textEditorView setHorizontallyResizable: YES];
        }
        
}

-(void)updateThemeManager
{
        [textEditorView setBackgroundColor:[[PLThemeManager defaultThemeManager] getThemeProperty:PLThemeManagerBackground
                                                                                        fromGroup:PLThemeManagerSettings]];
        [textEditorView setSelectedTextAttributes:@{NSBackgroundColorAttributeName:[[PLThemeManager defaultThemeManager] getThemeProperty:PLThemeManagerSelection
                                                                                                                                fromGroup:PLThemeManagerSettings]}];
        [scrollView setBackgroundColor:[[PLThemeManager defaultThemeManager] getThemeProperty:PLThemeManagerBackground
                                                                                    fromGroup:PLThemeManagerSettings]];
        
        [lineNumberView makeBackgroundColorFromColor:[[PLThemeManager defaultThemeManager] getThemeProperty:PLThemeManagerBackground
                                                                                                  fromGroup:PLThemeManagerSettings]];
        [lineNumberView setTextColor:[[PLThemeManager defaultThemeManager] getThemeProperty:PLThemeManagerForeground
                                                                                  fromGroup:PLThemeManagerSettings]];
        [lineNumberView setSelectedColor:[[PLThemeManager defaultThemeManager] getThemeProperty:PLThemeManagerLineHighlight
                                                                                      fromGroup:PLThemeManagerSettings]];
        [autocompleteViewController updateThemeManager];
}

-(void)updateFont:(NSFont *)font
{
        [textEditorView setFont:font];
        if ([autocompleteViewController respondsToSelector:@selector(updateFont:)])
                [autocompleteViewController updateFont:font];
        [self setColumnRuler:_columnRuler];
}

#pragma mark Add On Extension Protocol

+(id)viewController
{
        PLDocumentManager * documentManager = [PLDocumentManager sharedDocumentManager];
        return [self viewControllerWithDocument:[documentManager addTemporaryDocument:@"py"]];
}

+(id)viewControllerWithDocument:(id)document
{
        PLEditorViewController * viewController;
        viewController = [[self alloc] initWithNibName:@"PLEditorViewController"
                                                bundle:[NSBundle bundleForClass:self]];
        [viewController setTextDocument:document];
        return [viewController autorelease];
}

+(PLAddOnType)type
{
        return PLAddOnExtension;
}

#pragma mark Navigation Data Source

-(NSString *)navigationPopUpButton:(PLNavigationPopUpButton *)navigationPopUpButton titleForRange:(NSRange)range
{
        return [(PLNavigationItem *)[navigationDictionary objectForKey:[NSValue valueWithRange:range]] title];
}

-(NSImage *)navigationPopUpButton:(PLNavigationPopUpButton *)navigationPopUpButton imageForRange:(NSRange)range
{
        return [(PLNavigationItem *)[navigationDictionary objectForKey:[NSValue valueWithRange:range]] image];
}

-(NSArray *)rangesForNavigationPopUpButton:(PLNavigationPopUpButton *)navigationPopUpButton
{
        return [navigationDictionary allKeys];
}

#pragma mark Tab Subviews

+(NSString *)tabSubviewName
{
        return @"Text Editor";
}

-(BOOL)tabSubviewShouldClose:(id)sender
{
        BOOL shouldClose = NO;
        NSString * alert;
        NSInteger closeStatus;;
        if ([[PLDocumentManager sharedDocumentManager] documentIsEdited:textDocument] == NO) {
                shouldClose = YES;
                goto exit;
        } else if ([(NSData *)[textDocument documentData] length] == 0) {
                shouldClose = YES;
                goto exit;
        }
        alert = [NSString stringWithFormat:
                 @"Do you want to save the changes you made in the document “%@”?", [textDocument filename]];
        closeStatus = NSRunAlertPanel(@"Unsaved File", alert, @"Save", @"Don't Save", @"Cancel", nil);
        switch (closeStatus) {
                case NSAlertDefaultReturn:
                        [self saveFile:self];
                        shouldClose = [self tabSubviewShouldClose:self];
                        break;
                case NSAlertAlternateReturn:
                        shouldClose = YES;
                        break;
                case NSAlertOtherReturn:
                        shouldClose = NO;
                        break;
                default:
                        break;
        }
exit:
        return shouldClose;
}

#pragma mark Navigation

-(NSUInteger)numberOfItemsInNavigationPopUpButton:(PLNavigationPopUpButton *)navigationPopUpButton
{
        return [navigationDictionary count];
}

#pragma mark Save/Load File

-(IBAction)saveFile:(id)sender
{
        PLDocumentManager * documentManager = [PLDocumentManager sharedDocumentManager];
        if ([textDocument fileURL] == nil) {
                [self saveFileAs:self];
        } else {
                [documentManager saveDocument:textDocument atURL:[textDocument fileURL]];
        }
}

-(IBAction)saveFileAs:(id)sender
{
        NSNotificationCenter * defaultCenter = [NSNotificationCenter defaultCenter];
        PLDocumentManager * documentManager = [PLDocumentManager sharedDocumentManager];
        PLTextDocument * new = nil;
        new = [documentManager saveDocumentPanel:textDocument
                                  withExtensions:@[@"py"]];
        if (new == nil) {
                goto exit;
        }
        [defaultCenter removeObserver:self
                                 name:PLDocumentWasEditedNotification
                               object:textDocument];
        [defaultCenter removeObserver:self
                                 name:PLDocumentSavedStateChangedNotification
                               object:textDocument];
        [defaultCenter addObserver:self
                          selector:@selector(textDocumentDidChange:)
                              name:PLDocumentWasEditedNotification
                            object:new];
        [defaultCenter addObserver:self
                          selector:@selector(textDocumentSavedStateChanged:)
                              name:PLDocumentSavedStateChangedNotification
                            object:new];
        [new retain];
        [textDocument release];
        textDocument = new;
        [defaultCenter postNotificationName:PLTabSubviewTitleDidChangeNotification object:self];
        [defaultCenter postNotificationName:PLTabSubviewDocumentChangedSavedSateNotification object:self];
exit:
        return;
}

-(NSUndoManager *)undoManagerForTextView:(NSTextView *)view
{
        return [textDocument documentUndoManager];
}

-(id)document
{
        return textDocument;
}

#pragma mark - Private Methods -

#pragma mark Initialization/Deallocation

/**
 * \brief Initialize the PLEditorViewController with a nib bundle.
 *
 * \details Initialize all instance variables, including the scroll view, theme
 *          manager, syntax highlighter, text view properties, notification
 *          oberservers, and introspection controller with parsing timer on a
 *          10 second interval.
 *
 * \param nibNameOrNil The name of the nib to load.
 *
 * \param nibBundleOrNil The nib bundle to load.
 *
 * \return The initialized PLEditorViewController object.
 */
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
        NSError * setScriptError = nil;
        NSNotificationCenter * defaultCenter = [NSNotificationCenter defaultCenter];

        self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
        [self loadView];
        if (self) {
                lineNumberView = [[PLLineNumberView alloc] initWithScrollView:scrollView
                                                                  orientation:NSVerticalRuler];
                [scrollView setVerticalRulerView:lineNumberView];
                [scrollView setVerticalScroller:[[PLScroller new] autorelease]];
                [scrollView setRulersVisible:YES];
                [(PLScroller *)[scrollView verticalScroller] setDocumentView:textEditorView];
                [[scrollView verticalScroller] setNeedsDisplay:YES];
                [lineNumberView setClientView:textEditorView];
                gotoLineWindowController = [[PLGotoLineWindowController gotoLineWindowController] retain];
                
                syntaxHighlighter = [[PLSyntaxHighlighter alloc] init];
                if (syntaxHighlighter == nil) {
                        [self presentError:[NSError errorWithDomain:PLLiasisErrorDomain
                                                               code:PLErrorCodeStatusBar
                                                           userInfo:@{NSLocalizedDescriptionKey: @"Disabling syntax coloring.",
                                                                      NSLocalizedFailureReasonErrorKey: @"Error initializing coloring object."}]];
                }
                if ([syntaxHighlighter setActivePythonScript:@"python" error:&setScriptError] == NO) {
                        [self presentError:setScriptError];
                }
                
                [[textEditorView textStorage] setDelegate:self];
                [textEditorView setDelegate:self];
                
                [textEditorView setAutomaticTextReplacementEnabled:NO];
                [numberOfLinesField setDrawsBackground:NO];
                [numberOfLinesField setStringValue:@"1"];
                [[textEditorView layoutManager] replaceTextStorage:[[PLTextStorage new] autorelease]];
                [defaultCenter addObserver:self
                                  selector:@selector(textStorageWillReplaceCharacters:)
                                      name:PLTextStorageWillReplaceStringNotification
                                    object:[textEditorView textStorage]];
                [defaultCenter addObserver:self
                                  selector:@selector(textStorageDidReplaceCharacters:)
                                      name:PLTextStorageDidReplaceStringNotification
                                    object:[textEditorView textStorage]];
                [defaultCenter addObserver:self
                                  selector:@selector(textStorageDidProcessEditing:)
                                      name:NSTextStorageDidProcessEditingNotification
                                    object:[textEditorView textStorage]];
                formatter = [[PLFormatter alloc] init];
                [self setLineWrap:YES];
                [self setColumnRuler:80];
                
                id introspectionControllerAddOn = [[[PLAddOnManager defaultManager] loadedAddOnNamed:@"Introspector.plugin"] principalClass];
                pythonIntrospectionController = [[introspectionControllerAddOn alloc] init];
                if (pythonIntrospectionController) {
                        parseTimer = [[NSTimer scheduledTimerWithTimeInterval:10
                                                                       target:self
                                                                     selector:@selector(doParsing:)
                                                                     userInfo:nil
                                                                      repeats:YES] retain];
                        navigationDictionary = [[NSDictionary alloc] init];
                        [navigationPopUpButton setDataSource:self];
                        [navigationPopUpButton setDelegate:self];
                        autocompleteViewController = [[PLAutocompleteViewController viewControllerWithTextView:textEditorView] retain];
                } else {
                        [self presentError:[NSError errorWithDomain:PLLiasisErrorDomain
                                                               code:PLErrorCodeStatusBar
                                                           userInfo:@{NSLocalizedDescriptionKey: @"Disabling code introspection (autocomplete and navigation).",
                                                                      NSLocalizedFailureReasonErrorKey: @"Error initializing introspection controller"}]];
                }

                [textEditorView setAutoresizesSubviews:NO];
                [self updateThemeManager];
                [self updateFont:[[NSFontManager sharedFontManager] selectedFont]];
        }
        
        return self;
}

/**
 * \brief Deallocate the PLEditorViewController object.
 *
 * \details Release all instance variables, remove the object as an observer,
 *          and stop the parsing timer.
 */
-(void)dealloc
{
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [scrollView setVerticalRulerView:nil];
        [lineNumberView release];
        [gotoLineWindowController release];
        [syntaxHighlighter release];
        [pythonIntrospectionController release];
        [autocompleteViewController release];
        [navigationDictionary release];
        [parseTimer invalidate];
        [parseTimer release];
        [underliningTimer invalidate];
        [underliningTimer release];
        [textDocument release];
        [super dealloc];
}

#pragma mark Text View Properties

/**
 * \brief Return the title of the view.
 *
 * \details The title is a function of the save state. If unsaved, return
 *          "Untitled", otherwise return the name of the saved file, denoted
 *          with an asterisk if the file is modified but not saved.
 *
 * \return The view title.
 */
-(NSString *)title
{
        NSString * titleString;
        PLDocumentManager * documentManager = [PLDocumentManager sharedDocumentManager];
        if ([documentManager documentIsEdited:textDocument]) {
                titleString = [NSString stringWithFormat:
                               @"* %@",
                               [textDocument filename]];
        } else {
                titleString = [NSString stringWithFormat:
                               @"%@",
                               [textDocument filename]];
        }
        return titleString;
}

#pragma mark Responder Chain

/**
 * \brief NSResponder method prior to accepting first responder status.
 *
 * \details Set the window's first responder to the textEditorView.
 *
 * \return Always return YES, indicating that the view controller accepted
 *         first responder status.
 */
-(BOOL)becomeFirstResponder
{
        [[[self view] window] makeFirstResponder:textEditorView];
        return YES;
}

#pragma mark Document

-(void)setTextDocument:(PLTextDocument *)aDocument
{
        NSNotificationCenter * defaultCenter = [NSNotificationCenter defaultCenter];
        PLDocumentManager * documentManager = [PLDocumentManager sharedDocumentManager];
        if (textDocument)
                goto exit;
        [textEditorView replaceCharactersInRange:NSMakeRange(0, [[textEditorView string] length])
                                      withString:[aDocument currentString]];
        
        textDocument = [aDocument retain];
        [defaultCenter addObserver:self
                          selector:@selector(textDocumentDidChange:)
                              name:PLDocumentWasEditedNotification
                            object:textDocument];
        [defaultCenter addObserver:self
                          selector:@selector(textDocumentSavedStateChanged:)
                              name:PLDocumentSavedStateChangedNotification
                            object:textDocument];
        [[textEditorView textStorage] beginEditing];
        [[textEditorView textStorage] endEditing];
        [textEditorView setEditable:[documentManager documentIsEditable:[textDocument fileURL]]];
        [lockedImage setHidden:[textEditorView isEditable]];
exit:
        return;
}

#pragma mark Keystroke Interception

/**
 * \brief Intercept key bindings and perform an action.
 *
 * \details The following key bindings are intercepted:
 *              1) Cmd-/ calls PLFormatter method toggleComment:asBlock: with
 *                 asBlock = YES.
 *              2) Cmd-Opt-/ calls PLFormatter method toggleComment:asBlock:
 *                 with asBlock = NO.
 *              3) Cmd-] calls PLFormatter method
 *                 increaseIndentationOfSelection: in increase the indentation
 *                 level of text.
 *              4) Cmd-[ calls PLFormatter method
 *                 decreaseIndentationOfSelection: in decrease the indentation
 *                 level of text.
 *              5) Cmd-l opens the Go To Line window. Using the block handler,
 *                 move the cursor to the input line and column. The cursor is
 *                 never moved beyond the last column of the input line nor does
 *                 it attempt to move beyond the length of the text.
 *
 * \param theEvent The key binding event.
 *
 * \return A boolean if the event was performed.
 *
 * \see PLFormatter
 */
-(BOOL)performKeyEquivalent:(NSEvent *)theEvent
{
        BOOL performEquivalent = NO, hasCommand = NO, hasOption = NO;
        NSUInteger flags = 0, lineNumber = 0, column = 0;
        NSString * characters = nil;
        
        flags = [theEvent modifierFlags];
        characters = [theEvent charactersIgnoringModifiers];
        hasCommand = (flags & NSCommandKeyMask) != 0;
        hasOption = (flags & NSAlternateKeyMask) != 0;
        if ((flags & (NSShiftKeyMask | NSFunctionKeyMask | NSControlKeyMask)) != 0) {
                goto exit;
        }

        if (hasCommand) {
                if ([characters isEqualToString:@"/"]) {
                        if (hasOption)
                                [PLFormatter toggleCommentSelection:textEditorView asBlock:NO];
                        else
                                [PLFormatter toggleCommentSelection:textEditorView asBlock:YES];
                        isUnsaved = YES;
                        performEquivalent = YES;
                } else if ([characters isEqualToString:@"]"]) {
                        [PLFormatter increaseIndentationInSelection:textEditorView];
                        isUnsaved = YES;
                        performEquivalent = YES;
                } else if ([characters isEqualToString:@"["]) {
                        [PLFormatter decreaseIndentationInSelection:textEditorView];
                        isUnsaved = YES;
                        performEquivalent = YES;
                } else if ([characters isEqualToString:@"l"]) {
                        lineNumber = lineNumberForPosition([textEditorView string], [textEditorView selectedRange].location);
                        column = [textEditorView selectedRange].location - positionForLineNumber([textEditorView string], lineNumber) + 1;
                        [gotoLineWindowController showWindowWithLineNumber:lineNumber column:column gotoHandler:^(NSUInteger gotoLine, NSUInteger gotoColumn) {
                                NSUInteger lineIndex = positionForLineNumber([textEditorView string], gotoLine);
                                NSRange lineRange = [[textEditorView string] lineRangeForRange:NSMakeRange(lineIndex, 0)];
                                if (gotoColumn > lineRange.length)
                                        gotoColumn = lineRange.length;
                                
                                NSUInteger index = lineIndex + gotoColumn - 1;
                                if (index >= [[textEditorView string] length])
                                        index = [[textEditorView string] length];
                                [textEditorView setSelectedRange:NSMakeRange(index, 0)];
                                [textEditorView scrollRangeToVisible:NSMakeRange(index, 0)];
                        }];
                }
        }

exit:
        return performEquivalent;
}

#pragma mark Notifications and Delegate Methods

-(void)textDocumentSavedStateChanged:(NSNotification *)aNotification
{
        NSNotificationCenter * defaultCenter = [NSNotificationCenter defaultCenter];
        PLDocumentManager * documentManager = [PLDocumentManager sharedDocumentManager];
        [defaultCenter postNotificationName:PLTabSubviewTitleDidChangeNotification
                                     object:self];
        [defaultCenter postNotificationName:PLTabSubviewDocumentChangedSavedSateNotification
                                     object:self];
        [textEditorView setEditable:[documentManager documentIsEditable:[textDocument fileURL]]];
        [lockedImage setHidden:[textEditorView isEditable]];
}

-(void)textDocumentDidChange:(NSNotification *)aNotification
{
        PLTextStorage * textStorage = (PLTextStorage *)[textEditorView textStorage];
        if ([[textStorage string] isEqualToString:[textDocument currentString]])
                goto exit;
        [textStorage beginEditing];
        [textStorage replaceCharactersInRange:NSMakeRange(0, [textStorage length])
                                   withString:[textDocument currentString]];
        [textStorage endEditing];
exit:
        return;
}

/**
 * \brief Perform syntax coloring and display line numbers on notification.
 *
 * \details After the NSTextStorage object processed editing, perform syntax
 *          coloring in the edited range. Tell the line number view to display.
 *
 * \param aNotification The notification object (a NSTextStorage object).
 */
-(void)textStorageDidProcessEditing:(NSNotification *)aNotification
{
        NSError * coloringError = nil;
        NSTextStorage * textStorage = nil;

        if (syntaxHighlighter) {
                textStorage = [aNotification object];
                [textStorage beginEditing];
                if ([syntaxHighlighter colorTextStorage:textStorage error:&coloringError] == NO)
                        [self presentError:coloringError];
                [textStorage endEditing];
        }
        [textEditorView setNeedsDisplayInRect:[textEditorView visibleRect]];
        [lineNumberView setNeedsDisplay:YES];
        [(PLScroller *)[scrollView verticalScroller] setNeedsDisplay:YES];
}

/**
 * \brief Updated the line number ruler.
 *
 * \details Update the line number view values before the NSTextStorage object
 *          replaces characters.
 *
 * \param aNotification The notification object (a NSTextStorage object).
 */
-(void)textStorageWillReplaceCharacters:(NSNotification *)notification
{
        [lineNumberView updateLineNumbersForEditedRange:[[notification object] replacementRange]
                                  withReplacementString:[[notification object] replacementString]];
        if ([numberOfLinesField integerValue] != [lineNumberView numberOfLines]) {
                [numberOfLinesField setIntegerValue:[lineNumberView numberOfLines]];
                [statusText setStringValue:@""];
        }
        
        [formatter setPreviousEntryLocation:[[notification object] replacementRange].location];
}

-(void)textStorageDidReplaceCharacters:(NSNotification *)notification
{
        if ([[[textEditorView textStorage] string] isEqualToString:[textDocument currentString]])
                goto exit;
        [textDocument editCharactersInRange:[[notification object] replacementRange]
                                 withString:[[notification object] replacementString]];
exit:
        return;
}

/**
 * \brief Format the inserted text and clear underlined variables.
 *
 * \details The `PLFormatter` class is used here to format the `NSTextView`
 *          after an edit is performed. Set the `previousEntry` property of the
 *          formatter to the `replacementString`.
 *
 * \param textView The `NSTextView` that is being edited.
 *
 * \param affectedCharRange The range of characters that are edited.
 *
 * \param replacementString The string that will be inserted into the text view.
 *
 * \return YES if the `NSTextView` should edit the text.
 */
-(BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString
{
        BOOL changedText = [formatter didFormatTextView:textView
                                  withReplacementString:replacementString
                                                inRange:affectedCharRange];
        [formatter setPreviousEntry:replacementString];
        [textEditorView setUnderlinedRanges:nil];
        return !changedText;
}

/**
 * \brief Respond to changes in selection and insertion point movement.
 *
 * \details This delegate method is implemented in order to provide open bracket
 *          highlighting and update the title of the navigation popup button.
 *
 *          Open bracket highlighting occurs if all of the following conditions
 *          are met:
 *              1) Cursor moves.
 *              2) Cursor moves without selecting.
 *              3) Motion is forward by one character.
 *          The open bracket is highlighted with the animateCharacter:atPosition
 *          method.
 *
 *          Select the item in the navigationPopUpButton with the line number of
 *          newSelectedCharRange.
 *
 * \param textView The NSTextView where selection is occurring.
 *
 * \param oldSelectedCharRange The previous range of characters.
 *
 * \param newSelectedCharRange The new range of characters.
 *
 * \return The new selection range. This is unchanged from the
 *         newSelectedCharRange as this method is only implemented to respond to
 *         selection changes, not modify them.
 */
-(NSRange)textView:(NSTextView *)aTextView willChangeSelectionFromCharacterRange:(NSRange)oldSelectedCharRange toCharacterRange:(NSRange)newSelectedCharRange
{
        NSUInteger lineNumber = 0;

        if (oldSelectedCharRange.location == newSelectedCharRange.location - 1 && newSelectedCharRange.length == 0)
                [self animateBracketInTextView:aTextView matchingPosition:oldSelectedCharRange.location];

        lineNumber = lineNumberForPosition([textEditorView string], newSelectedCharRange.location);
        [navigationPopUpButton selectNavigationItemWithLineNumber:lineNumber];
        return newSelectedCharRange;
}

-(void)textViewDidChangeSelection:(NSNotification *)notification
{
        NSUInteger insertionPoint = [[notification object] selectedRange].location;
        
        if (pythonIntrospectionController) {
                /* Check if insertion point is still in an underlined word */
                for (NSValue * range in [textEditorView underlinedRanges]) {
                        if (NSLocationInRange(insertionPoint, [range rangeValue])) {
                                goto exit;
                        }
                }
                
                /* Clear all underlining and restart the timer */
                [textEditorView setUnderlinedRanges:nil];
                [self startUnderliningTimer];
        }

exit:
        return;

}

-(NSArray *)textView:(NSTextView *)textView completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index
{
        [self parseText];
        NSString * partialWord = [[textView string] substringWithRange:charRange];
        NSMutableArray * completionArray = [NSMutableArray arrayWithArray:@[]];
        for (NSString * word in [[autocompleteVariables allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]) {
                if ([word length] >= charRange.length) {
                        NSString * comparisonWord = [word substringToIndex:charRange.length];
                        if ([comparisonWord compare:partialWord options:NSCaseInsensitiveSearch] == NSOrderedSame)
                                [completionArray addObject:word];
                }
        }
        return [NSArray arrayWithArray:completionArray];
}

/**
 * \brief Intercept the `cancelOperation:` selector to toggle displaying the
 *        autocompletion options.
 *
 * \param textView The text view.
 *
 * \param commandSelector The selector.
 *
 * \return YES if the selector was `cancelOperation:` and NO otherwise.
 */
-(BOOL)textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
        NSString *aSelector;
        BOOL didCommand = NO;
        aSelector = [NSStringFromSelector(commandSelector) retain];
        
        if ([aSelector isEqualToString:@"cancelOperation:"]) {
                [autocompleteViewController toggleDisplayAutocompletions];
                didCommand = YES;
        }
        
exit:
        [aSelector release];
        return didCommand;
}

/**
 * \brief Jump to the navigation item in the text when clicking a menu item.
 *
 * \details Find the line range in the textEditorView for the line number of the
 *          range. Find the first and last non-whitespace indices of the line
 *          and select the range of the line between these locations. Finally,
 *          scroll the textEditorView to the new selection.
 *
 * \param sender The menu item that was clicked.
 */
-(void)navigationPopUpButton:(PLNavigationPopUpButton *)navigationPopUpButton didClickMenuItemWithRange:(NSRange)range
{
        NSString * text = nil;
        NSUInteger startIndex = 0, endIndex = 0, lineNumber = 0;
        NSRange lineRange, selectionRange;
        NSCharacterSet * nonWhitespaceCharacters = nil;

        lineNumber = range.location;
        text = [textEditorView string];
        lineRange = [text lineRangeForRange:NSMakeRange(positionForLineNumber(text, lineNumber), 0)];
        nonWhitespaceCharacters = [[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet];
        startIndex = [text rangeOfCharacterFromSet:nonWhitespaceCharacters
                                           options:0
                                             range:lineRange].location;
        endIndex = NSMaxRange([text rangeOfCharacterFromSet:nonWhitespaceCharacters
                                                    options:NSBackwardsSearch
                                                      range:lineRange]);
        selectionRange = NSMakeRange(startIndex, endIndex - startIndex);
        [textEditorView setSelectedRange:selectionRange];
        [textEditorView scrollRangeToVisible:selectionRange];
}

#pragma mark Animations

/**
 * \brief Apply a bounce highlight to an opening bracket in a NSTextView.
 *
 * \details The animation uses the formatter to find the matching open bracket
 *          and animates it using the NSTextView showFindIndicatorForRange:
 *          method to animate it.
 *
 * \param aTextView The NSTextView to apply the animation.
 *
 * \param position The position to highlight.
 */
-(void)animateBracketInTextView:(NSTextView *)aTextView matchingPosition:(NSUInteger)position
{
        char charAtPosition;
        NSCharacterSet * bracesCharacterSet;
        NSUInteger openBraceLocation;

        charAtPosition = [[aTextView string] characterAtIndex:position];
        bracesCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"]})"];        
        if ([bracesCharacterSet characterIsMember:charAtPosition]) {
                openBraceLocation = [PLFormatter characterIndexForNextOpenBracket:[aTextView string]
                                                                        fromIndex:position];
                if (openBraceLocation != NSNotFound)
                        [textEditorView showFindIndicatorForRange:NSMakeRange(openBraceLocation, 1)];
        }
}

#pragma mark Source Code Parsing

/**
 * \brief Parse the source file for autocomplete variables and navigation
 *        dictionary.
 *
 * \details Determine the current line number and parse the text at that line.
 *          If the parsing is successful, update the autocompleteVariables
 *          array. If it failes, do not update the array, falling back to the
 *          previous version. Update the navigation popup button.
 *
 *          Retrieve the navigationDictionary from the introspection controller
 *          and send the reloadData message to the navigationoPopUpButton.
 *
 * \return YES if parsing was successful.
 */
-(BOOL)parseText
{
        SEL parseSelector = @selector(parseSource:error:);
        SEL variablesSelector = @selector(variablesWithIndex:error:);
        SEL navigationSelector = @selector(getNavigationAndReturnError:);
        BOOL parseSuccessful = YES;
        BOOL errorOccurred = NO;
        NSMethodSignature * parseMethodSignature = nil;
        NSMethodSignature * variablesMethodSignature = nil;
        NSMethodSignature * navigationMethodSignature = nil;
        NSInvocation * parseInvocation = nil;
        NSInvocation * variablesInvocation = nil;
        NSInvocation * navigationInvocation = nil;
        NSError * error = nil;
        NSError ** errorPointer = &error;
        NSString * textString = nil;
        NSUInteger insertionPoint = 0;
        NSDictionary * variables = nil;
        NSDictionary * navigation = nil;

        /* Parse source */
        if ([pythonIntrospectionController respondsToSelector:parseSelector]) {
                textString = [textEditorView string];
                parseMethodSignature = [[pythonIntrospectionController class] instanceMethodSignatureForSelector:parseSelector];
                parseInvocation = [NSInvocation invocationWithMethodSignature:parseMethodSignature];
                [parseInvocation setSelector:parseSelector];
                [parseInvocation setTarget:pythonIntrospectionController];
                [parseInvocation setArgument:&textString atIndex:2];
                [parseInvocation setArgument:&errorPointer atIndex:3];
                [parseInvocation invoke];
                [parseInvocation getReturnValue:&parseSuccessful];

                if (parseSuccessful == NO) {
                        errorOccurred = YES;
                        goto exit;
                }
        }

        /* Update autocomplete variables */
        if ([pythonIntrospectionController respondsToSelector:variablesSelector]) {
                insertionPoint = [textEditorView selectedRange].location;
                variablesMethodSignature = [[pythonIntrospectionController class] instanceMethodSignatureForSelector:variablesSelector];
                variablesInvocation = [NSInvocation invocationWithMethodSignature:variablesMethodSignature];
                [variablesInvocation setSelector:variablesSelector];
                [variablesInvocation setTarget:pythonIntrospectionController];
                [variablesInvocation setArgument:&insertionPoint atIndex:2];
                [variablesInvocation setArgument:&errorPointer atIndex:3];
                [variablesInvocation invoke];
                [variablesInvocation getReturnValue:&variables];

                if (variables) {
                        [autocompleteVariables release];
                        autocompleteVariables = [variables retain];
                } else {
                        errorOccurred = YES;
                        goto exit;
                }
        }
        
        /* Update navigation dictionary */
        if ([pythonIntrospectionController respondsToSelector:navigationSelector]) {
                navigationMethodSignature = [[pythonIntrospectionController class] instanceMethodSignatureForSelector:navigationSelector];
                navigationInvocation = [NSInvocation invocationWithMethodSignature:navigationMethodSignature];
                [navigationInvocation setSelector:navigationSelector];
                [navigationInvocation setTarget:pythonIntrospectionController];
                [navigationInvocation setArgument:&errorPointer atIndex:2];
                [navigationInvocation invoke];
                [navigationInvocation getReturnValue:&navigation];

                if (navigation) {
                        [navigationDictionary release];
                        navigationDictionary = [navigation retain];
                        [navigationPopUpButton reloadData];
                } else {
                        errorOccurred = YES;
                        goto exit;
                }
        }

exit:
        // TODO: improve error handling here
//        if (errorOccurred)
//                [self presentError:error];
        return parseSuccessful;
}

/**
 * \brief Parse the text at the timer termination.
 *
 * \details Simply call the `parseText` method.
 *
 * \param timer The timer calling this method.
 */
-(void)doParsing:(NSTimer *)timer
{
        [self parseText];
}

#pragma mark Underlining

-(void)underlineText
{
        SEL rangesSelector = @selector(variableRangesWithIndex:error:);
        NSArray * ranges = nil;
        NSMethodSignature * rangesMethodSignature = nil;
        NSInvocation * rangesInvocation = nil;
        NSError * error = nil;
        NSError ** errorPointer = &error;
        NSUInteger insertionPoint = 0;
        BOOL parseSuccessful = YES;

        /* Do nothing if the autocomplete view is visible */
        if (autocompleteViewController && [[autocompleteViewController view] isHidden] == NO) {
                goto exit;
        }
        
        /* Get ranges to underline */
        [textEditorView setUnderlinedRanges:nil];
        parseSuccessful = [self parseText];
        if ([pythonIntrospectionController respondsToSelector:rangesSelector]) {
                insertionPoint = [textEditorView selectedRange].location;
                rangesMethodSignature = [[pythonIntrospectionController class] instanceMethodSignatureForSelector:rangesSelector];
                rangesInvocation = [NSInvocation invocationWithMethodSignature:rangesMethodSignature];
                [rangesInvocation setSelector:rangesSelector];
                [rangesInvocation setTarget:pythonIntrospectionController];
                [rangesInvocation setArgument:&insertionPoint atIndex:2];
                [rangesInvocation setArgument:&errorPointer atIndex:3];
                [rangesInvocation invoke];
                [rangesInvocation getReturnValue:&ranges];

                if (ranges == nil) {
//                        [self presentError:error];
                } else if ([ranges count] > 1) {
                        /* If parsing failed, check that all ranges consist of
                         * the same variable before underlining because it will
                         * fall back on a previous version of the source.
                         */
                        if (parseSuccessful == NO) {
                                for (NSValue * range in ranges) {
                                        if (NSMaxRange([range rangeValue]) >= [[textEditorView string] length] ||
                                            [[[textEditorView string] substringWithRange:[range rangeValue]] isEqualToString:
                                             [[textEditorView string] substringWithRange:[[ranges objectAtIndex:0] rangeValue]]] == NO) {
                                                goto exit;
                                        }
                                }
                        }
                        [textEditorView setUnderlinedRanges:ranges];
                }
        }

exit:
        return;
}

-(void)doUnderlining:(NSTimer *)timer
{
        [self underlineText];
}

-(void)startUnderliningTimer
{
        NSTimeInterval interval = 0.25;
        [self stopUnderliningTimer];
        underliningTimer = [[NSTimer scheduledTimerWithTimeInterval:interval
                                                             target:self
                                                           selector:@selector(doUnderlining:)
                                                           userInfo:nil
                                                            repeats:NO] retain];
}

-(void)stopUnderliningTimer
{
        [underliningTimer invalidate];
        [underliningTimer release];
}

@end
