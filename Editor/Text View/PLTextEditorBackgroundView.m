/**
 * \file PLTextEditorBackgroundView.m
 * \brief Liasis Python IDE background view for the text editor.
 *
 * \details This file contains the implementation for the background view of the
 *          text editor.
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

#import "PLTextEditorBackgroundView.h"

@implementation PLTextEditorBackgroundView

/**
 * \brief Draw the view.
 *
 * \details Fills the rect with the background color.
 *
 * \param dirtyRect The portion of the view to be drawn.
 */
-(void)drawRect:(NSRect)dirtyRect
{
        [_backgroundColor setFill];
        NSRectFill(dirtyRect);
}

@end
