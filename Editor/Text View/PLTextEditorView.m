/**
 * \file PLTextEditorView.m
 * \brief Liasis Python IDE text editor NSTextView subclass.
 *
 * \details
 * This file contains the implementation for a NSTextView subclass view
 * subclass to be used by the PLEditorViewController.
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

#import "PLTextEditorView.h"

@implementation PLTextEditorView

#pragma mark - Object Lifecycle

/**
 * \brief The designated initializer for NSTextView.
 *
 * \details Initialize self with the initialize method.
 *
 * \param frameRect The frame of the text view.
 *
 * \param textContainer The text container of the text view.
 *
 * \returns The initialized text view.
 */
-(instancetype)initWithFrame:(NSRect)frameRect textContainer:(NSTextContainer *)container
{
        self = [super initWithFrame:frameRect textContainer:container];
        if (self) {
                [self initialize];
        }
        return self;
}

/**
 * \brief Initialize self when loaded from a nib file.
 */
-(void)awakeFromNib
{
        [self initialize];
}

/**
 * \brief The main initialization method.
 *
 * \details Observe the PLThemeManagerDidChange notification and force an update
 *          of the theme manager in case it was update prior to initialization.
 */
-(void)initialize
{
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateThemeManager)
                                                     name:PLThemeManagerDidChange
                                                   object:nil];
        [self updateThemeManager];
}

/**
 * \brief Release the rulerColor ivar and remove self from notification center.
 */
-(void)dealloc
{
        [rulerColor release];
        [_underlinedRanges release];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [super dealloc];
}

#pragma mark - Properties

-(void)setUnderlinedRanges:(NSArray *)underlinedRanges
{
        [underlinedRanges retain];
        [_underlinedRanges release];
        _underlinedRanges = underlinedRanges;
        [self setNeedsDisplayInRect:[self visibleRect]];
}

#pragma mark - Drawing

/**
 * \brief Draw a vertical column ruler line and underline ranges in the text.
 *
 * \details This method first calls the superclass method. Then it draws a
 *          vertical line at the x position specified by `columnRuler` from the
 *          bottom to top of the `visibleRect`. Finally, it draws a rounded
 *          underline in all ranges of `underlinedRanges`.
 *
 * \param rect The rect to draw.
 */
-(void)drawViewBackgroundInRect:(NSRect)rect
{
        NSRange glyphRange;
        NSRect columnRect, charRect;
        NSPoint p0, p1, p2, p3;
        NSBezierPath * underlinePath = nil;
        CGFloat lineDash[2] = {5.0f, 1.0f};
        CGFloat rectRadius = 2.0f;

        [super drawViewBackgroundInRect:rect];
        
        /* Draw the column ruler */
        [rulerColor set];
        columnRect = NSMakeRect([self columnRuler],
                                [self frame].origin.y,
                                1,
                                [self frame].size.height);
        NSRectFill(columnRect);
        
        /* Draw variable underlining */
        for (NSValue * range in _underlinedRanges) {
                glyphRange = [[self layoutManager] glyphRangeForCharacterRange:[range rangeValue] actualCharacterRange:NULL];
                charRect = [[self layoutManager] boundingRectForGlyphRange:glyphRange inTextContainer:[self textContainer]];
                underlinePath = [NSBezierPath bezierPath];
                
                p0 = NSMakePoint(NSMinX(charRect), NSMidY(charRect));  // initial point (halfway up left side)
                p1 = NSMakePoint(NSMinX(charRect), NSMaxY(charRect));  // bottom-left corner
                p2 = NSMakePoint(NSMaxX(charRect), NSMaxY(charRect));  // bottom-right corner
                p3 = NSMakePoint(NSMaxX(charRect), NSMidY(charRect));  // end point (halfway up right side)
                
                [underlinePath moveToPoint:p0];
                [underlinePath appendBezierPathWithArcFromPoint:p1 toPoint:p2 radius:rectRadius];
                [underlinePath appendBezierPathWithArcFromPoint:p2 toPoint:p3 radius:rectRadius];
                [underlinePath lineToPoint:NSMakePoint(NSMaxX(charRect), NSMidY(charRect))];
                
                [underlinePath setLineDash:lineDash count:2 phase:0.0f];
                [[[PLThemeManager defaultThemeManager] getThemeProperty:PLThemeManagerForeground
                                                              fromGroup:PLThemeManagerSettings] set];
                [underlinePath stroke];
        }
}

/**
 * \brief Method called when the application theme manager changes.
 *
 * \details Update the color of the column ruler. The column ruler color is the
 *          foreground color blended with that of the background.
 */
-(void)updateThemeManager
{
        NSColor * foreground = [[PLThemeManager defaultThemeManager] getThemeProperty:PLThemeManagerForeground
                                                                            fromGroup:PLThemeManagerSettings];
        NSColor * background = [[PLThemeManager defaultThemeManager] getThemeProperty:PLThemeManagerBackground
                                                                            fromGroup:PLThemeManagerSettings];
        [rulerColor release];
        rulerColor = [[foreground blendedColorWithFraction:0.4 ofColor:background] retain];
}

@end
