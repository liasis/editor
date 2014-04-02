/**
 * \file PLTextEditorView.h
 * \brief Liasis Python IDE text editor NSTextView subclass.
 *
 * \details
 * This file contains the interface for a NSTextView subclass view subclass to
 * be used by the PLEditorViewController.
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
 * \see PLEditorViewController.
 */

#import <Cocoa/Cocoa.h>
#import <LiasisKit/LiasisKit.h>

/**
 * \class PLTextEditorView \headerfile \headerfile
 *
 * \brief A NSTextView subclass that draws a column ruler and can highlight
 *        particular words with a rounded underline.
 *
 * \details This class implements the `drawViewBackgroundInRect:` method of its
 *          superclass to draw a column ruler on the text view and the custom
 *          underlining. It observes changes to the theme manager to set the
 *          color of the column ruler and the underlines.
 *
 * \superclass NSTextView
 */
@interface PLTextEditorView : NSTextView <PLThemeable>
{
        /**
         * \brief The color of the vertical column ruler.
         */
        NSColor * rulerColor;
}

/**
 * \brief The x position to draw a vertical column ruler.
 */
@property NSUInteger columnRuler;

/**
 * \brief An array of word ranges that are to be be underlined.
 *
 * \details Setting this property causes the view to update its display in
 *          the visible rect.
 */
@property (nonatomic, retain) NSArray * underlinedRanges;

@end
