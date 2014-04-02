/**
 * \file PLGotoLineWindowController.m
 * \brief Liasis Python IDE window controller for the Go To Line window.
 *
 * \details This file contains the implementation for the Go To Line window
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

#import "PLGotoLineWindowController.h"

@implementation PLGotoLineWindowController

+(instancetype)gotoLineWindowController
{
        return [[[PLGotoLineWindowController alloc] initWithWindowNibName:@"PLGotoLineWindowController"] autorelease];
}

/**
 * \brief Release the block goto handler and close the window.
 */
-(void)dealloc
{
        Block_release(gotoHandler);
        [[self window] close];
        [super dealloc];
}

-(void)showWindowWithLineNumber:(NSUInteger)lineNumber column:(NSUInteger)column gotoHandler:(void (^)(NSUInteger gotoLine, NSUInteger gotoColumn))handler
{
        NSString * text = [NSString stringWithFormat:@"%lu:%lu", lineNumber, column];
        if ([self isWindowLoaded] == NO)
                [self window];
        [textField setStringValue:text];
        Block_release(gotoHandler);
        gotoHandler = Block_copy(handler);
        [[self window] makeKeyAndOrderFront:self];
}

/**
 * \brief Close the window if the user selects the Cancel button.
 *
 * \param sender The sender of the action.
 */
-(IBAction)cancelAction:(id)sender
{
        [[self window] close];
}

/**
 * \brief Parse the user input if they select the Go button.
 *
 * \details Uses NSNumberFormatter to parse the input string. Only the first
 *          two components of the string are used after separating the string
 *          by the ':' character. The number formatter handles both the minimum
 *          value and the rounding of floats (by not generating decimal
 *          numbers). If the number formatter cannot parse the string, the
 *          defaults are 1 and 1 for line and column, respectively.
 *
 * \param sender The sender of the action.
 */
-(IBAction)goAction:(id)sender
{
        NSNumber * lineNumber = nil, * column = nil;
        NSString * text = [textField stringValue];
        NSArray * components = [text componentsSeparatedByString:@":"];
        NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
        NSUInteger minValue = 1;
        
        [formatter setMinimum:[NSNumber numberWithUnsignedInteger:minValue]];
        [formatter setGeneratesDecimalNumbers:NO];

        if ([components count] >= 1 && [[textField stringValue] isEqualToString:@""] == NO) {
                lineNumber = [formatter numberFromString:[components objectAtIndex:0]];
                if ([components count] >= 2)
                        column = [formatter numberFromString:[components objectAtIndex:1]];
                gotoHandler(lineNumber ? [lineNumber unsignedIntegerValue] : minValue,
                            column ? [column unsignedIntegerValue] : minValue);
        }
        [formatter release];
        [[self window] close];
}

@end
