//
//  THLabel.m
//
//  Version 1.0.3
//
//  Created by Tobias Hagemann on 11/25/12.
//  Copyright (c) 2013 tobiha.de. All rights reserved.
//
//  Original source and inspiration from:
//  FXLabel by Nick Lockwood,
//  https://github.com/nicklockwood/FXLabel
//  KSLabel by Kai Schweiger,
//  https://github.com/vigorouscoding/KSLabel
//
//  Distributed under the permissive zlib license
//  Get the latest version from here:
//
//  https://github.com/MuscleRumble/THLabel
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import "THLabel.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_6_0
typedef enum {
	NSTextAlignmentLeft = UITextAlignmentLeft,
	NSTextAlignmentCenter = UITextAlignmentCenter,
	NSTextAlignmentRight = UITextAlignmentRight
} NSTextAlignment;
#endif

@implementation THLabel

@synthesize shadowBlur = _shadowBlur;
@synthesize strokeSize = _strokeSize, strokeColor = _strokeColor, strokePosition = _strokePosition;
@synthesize gradientStartColor = _gradientStartColor, gradientEndColor = _gradientEndColor, gradientColors = _gradientColors, gradientStartPoint = _gradientStartPoint, gradientEndPoint = _gradientEndPoint;
@synthesize textInsets = _textInsets;

#pragma mark -
#pragma mark Accessors and Mutators

- (UIColor *)gradientStartColor {
	return [self.gradientColors count] ? [self.gradientColors objectAtIndex:0] : nil;
}

- (void)setGradientStartColor:(UIColor *)gradientStartColor {
	if (gradientStartColor == nil) {
		self.gradientColors = nil;
	} else if ([self.gradientColors count] < 2) {
		self.gradientColors = [NSArray arrayWithObjects:gradientStartColor, gradientStartColor, nil];
	} else if ([self.gradientColors objectAtIndex:0] != gradientStartColor) {
		NSMutableArray *colors = [self.gradientColors mutableCopy];
		[colors replaceObjectAtIndex:0 withObject:gradientStartColor];
		self.gradientColors = colors;
	}
}

- (UIColor *)gradientEndColor {
	return [self.gradientColors lastObject];
}

- (void)setGradientEndColor:(UIColor *)gradientEndColor {
	if (gradientEndColor == nil) {
		self.gradientColors = nil;
	} else if ([self.gradientColors count] < 2) {
		self.gradientColors = [NSArray arrayWithObjects:gradientEndColor, gradientEndColor, nil];
	} else if ([self.gradientColors lastObject] != gradientEndColor) {
		NSMutableArray *colors = [self.gradientColors mutableCopy];
		[colors replaceObjectAtIndex:[colors count] - 1 withObject:gradientEndColor];
		self.gradientColors = colors;
	}
}

- (void)setGradientColors:(NSArray *)gradientColors {
	if (self.gradientColors != gradientColors) {
		_gradientColors = [gradientColors copy];
		[self setNeedsDisplay];
	}
}

- (void)setTextInsets:(UIEdgeInsets)textInsets {
	if (!UIEdgeInsetsEqualToEdgeInsets(self.textInsets, textInsets)) {
		_textInsets = textInsets;
		[self setNeedsDisplay];
	}
}

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(CGRect)rect {
	// Get everything ready for drawing.
	CGRect contentRect = [self contentRectFromBounds:self.bounds withInsets:self.textInsets];
	CGFloat fontSize = self.font.pointSize;
	CGRect textRect = [self textRectFromContentRect:contentRect actualFontSize:&fontSize];
	UIFont *font = [self.font fontWithSize:fontSize];
	
	// Determine what has to be drawn.
	BOOL hasShadow = self.shadowColor && ![self.shadowColor isEqual:[UIColor clearColor]] && (self.shadowBlur > 0.0f || !CGSizeEqualToSize(self.shadowOffset, CGSizeZero));
	BOOL hasStroke = self.strokeSize > 0 && ![self.strokeColor isEqual:[UIColor clearColor]];
	BOOL hasGradient = [self.gradientColors count] > 1;
	BOOL needsMask = hasGradient || (hasStroke && self.strokePosition == THLabelStrokePositionInside);
	
	// -------
	// Step 1: Begin new drawing context, where we will apply all our styles.
	// -------
	
	UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGImageRef alphaMask = NULL;
	
	// -------
	// Step 2: Prepare mask.
	// -------
	
	if (needsMask) {
		CGContextSaveGState(context);
		
		if (hasStroke) {
			// Text needs invisible stroke for consistent character glyph widths.
			CGContextSetTextDrawingMode(context, kCGTextFillStroke);
			
			// Set stroke attributes.
			[self setStrokeAttributesInContext:context];
			
			// Set invisible stroke.
			[[UIColor clearColor] setStroke];
		} else {
			CGContextSetTextDrawingMode(context, kCGTextFill);
		}
		
		// Set white color for alpha mask.
		[[UIColor whiteColor] setFill];
		
		// Draw alpha mask.
		[self drawTextInRect:textRect withFont:font];
		
		// Save alpha mask.
		alphaMask = CGBitmapContextCreateImage(context);
		
		// Clear the content.
		CGContextClearRect(context, rect);
		
		CGContextRestoreGState(context);
	}
	
	// -------
	// Step 3: Draw text normally, or with gradient.
	// -------
	
	CGContextSaveGState(context);
	
	if (!hasGradient) {
		if (hasStroke) {
			// Text needs invisible stroke for consistent character glyph widths.
			CGContextSetTextDrawingMode(context, kCGTextFillStroke);
			
			// Set stroke attributes.
			[self setStrokeAttributesInContext:context];
			
			// Set invisible stroke.
			[[UIColor clearColor] setStroke];
		} else {
			CGContextSetTextDrawingMode(context, kCGTextFill);
		}
		
		// Set text fill color.
		[self.textColor setFill];
		
		// Draw text.
		[self drawTextInRect:textRect withFont:font];
	} else {
		// Invert everything, because CG works with an inverted coordinate system.
		CGContextTranslateCTM(context, 0.0f, rect.size.height);
		CGContextScaleCTM(context, 1.0f, -1.0f);
		
		// Clip the current context to alpha mask.
		CGContextClipToMask(context, rect, alphaMask);
		
		// Invert back to draw the gradient correctly.
		CGContextTranslateCTM(context, 0.0f, rect.size.height);
		CGContextScaleCTM(context, 1.0f, -1.0f);
		
		// Get gradient colors as CGColor.
		NSMutableArray *gradientColors = [NSMutableArray arrayWithCapacity:[self.gradientColors count]];
		
		for (UIColor *color in self.gradientColors) {
			[gradientColors addObject:(__bridge id)color.CGColor];
		}
		
		// Create gradient.
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, NULL);
		CGPoint startPoint = CGPointMake(textRect.origin.x + self.gradientStartPoint.x * textRect.size.width,
										 textRect.origin.y + self.gradientStartPoint.y * textRect.size.height);
		CGPoint endPoint = CGPointMake(textRect.origin.x + self.gradientEndPoint.x * textRect.size.width,
									   textRect.origin.y + self.gradientEndPoint.y * textRect.size.height);
		
		// Draw gradient.
		CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
		
		// Clean up, because ARC doesn't handle CG.
		CGColorSpaceRelease(colorSpace);
		CGGradientRelease(gradient);
	}
	
	CGContextRestoreGState(context);
	
	// -------
	// Step 4: Draw stroke.
	// -------
	
	if (hasStroke) {
		CGContextSaveGState(context);
		
		CGContextSetTextDrawingMode(context, kCGTextStroke);
		
		CGImageRef image = NULL;
		
		if (self.strokePosition == THLabelStrokePositionOutside) {
			// Create an image from the text.
			image = CGBitmapContextCreateImage(context);
		}
		
		// Set stroke attributes.
		[self setStrokeAttributesInContext:context];
		
		// Set stroke color.
		[self.strokeColor setStroke];
		
		if (self.strokePosition == THLabelStrokePositionInside) {
			// Invert everything, because CG works with an inverted coordinate system.
			CGContextTranslateCTM(context, 0.0f, rect.size.height);
			CGContextScaleCTM(context, 1.0f, -1.0f);
			
			// Clip the current context to alpha mask.
			CGContextClipToMask(context, rect, alphaMask);
			
			// Invert back to draw the stroke correctly.
			CGContextTranslateCTM(context, 0.0f, rect.size.height);
			CGContextScaleCTM(context, 1.0f, -1.0f);
		}
		
		// Draw stroke.
		[self drawTextInRect:textRect withFont:font];
		
		if (self.strokePosition == THLabelStrokePositionOutside) {
			// Invert everything, because CG works with an inverted coordinate system.
			CGContextTranslateCTM(context, 0.0f, rect.size.height);
			CGContextScaleCTM(context, 1.0f, -1.0f);
			
			// Draw the saved image over half of the stroke.
			CGContextDrawImage(context, rect, image);
			
			// Clean up, because ARC doesn't handle CG.
			CGImageRelease(image);
		}
		
		CGContextRestoreGState(context);
	}
	
	// -------
	// Step 5: Draw shadow.
	// -------
	
	if (hasShadow) {
		CGContextSaveGState(context);
		
		// Create an image from the text.
		CGImageRef image = CGBitmapContextCreateImage(context);
		
		// Clear the content.
		CGContextClearRect(context, rect);
		
		// Invert everything, because CG works with an inverted coordinate system.
		CGContextTranslateCTM(context, 0.0f, rect.size.height);
		CGContextScaleCTM(context, 1.0f, -1.0f);
		
		// Set shadow attributes.
		CGContextSetShadowWithColor(context, self.shadowOffset, self.shadowBlur, self.shadowColor.CGColor);
		
		// Draw the saved image, which throws off a shadow.
		CGContextDrawImage(context, rect, image);
		
		// Clean up, because ARC doesn't handle CG.
		CGImageRelease(image);
		
		CGContextRestoreGState(context);
	}
	
	// -------
	// Step 6: End drawing context and finally draw the text with all styles.
	// -------
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	[image drawInRect:rect];
	
	if (needsMask) {
		CGImageRelease(alphaMask);
	}
}

- (void)drawTextInRect:(CGRect)rect withFont:(UIFont *)font {
	if (self.adjustsFontSizeToFitWidth && self.numberOfLines == 1 && font.pointSize < self.font.pointSize) {
		CGFloat fontSize = 0.0f;
		[self.text drawAtPoint:rect.origin forWidth:rect.size.width withFont:self.font minFontSize:font.pointSize actualFontSize:&fontSize lineBreakMode:self.lineBreakMode baselineAdjustment:self.baselineAdjustment];
	} else {
		[self.text drawInRect:rect withFont:font lineBreakMode:self.lineBreakMode alignment:self.textAlignment];
	}
}

- (CGRect)contentRectFromBounds:(CGRect)bounds withInsets:(UIEdgeInsets)insets {
	CGRect contentRect = CGRectMake(0.0f, 0.0f, bounds.size.width, bounds.size.height);
	
	// Apply insets.
	contentRect.origin.x += insets.left;
	contentRect.origin.y += insets.top;
	contentRect.size.width -= insets.left + insets.right;
	contentRect.size.height -= insets.top + insets.bottom;
	
	return contentRect;
}

- (void)setStrokeAttributesInContext:(CGContextRef)context {
	switch (self.strokePosition) {
		case THLabelStrokePositionCenter:
			CGContextSetLineWidth(context, self.strokeSize);
			CGContextSetLineJoin(context, kCGLineJoinRound);
			break;
			
		default:
			// Stroke width times 2, because CG draws a centered stroke. We cut the rest into halves.
			CGContextSetLineWidth(context, self.strokeSize * 2.0f);
			CGContextSetLineJoin(context, kCGLineJoinRound);
			break;
	}
}

- (CGRect)textRectFromContentRect:(CGRect)contentRect actualFontSize:(CGFloat *)actualFontSize {
	CGRect textRect = contentRect;
	CGFloat minFontSize;
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
	if ([self respondsToSelector:@selector(minimumScaleFactor)]) {
		minFontSize = self.minimumScaleFactor ? self.minimumScaleFactor * *actualFontSize : *actualFontSize;
	} else {
#endif
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
		minFontSize = self.minimumFontSize ? : *actualFontSize;
#endif
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
	}
#endif
	
	// Calculate text rect size.
	if (self.adjustsFontSizeToFitWidth && self.numberOfLines == 1) {
		textRect.size = [self.text sizeWithFont:self.font minFontSize:minFontSize actualFontSize:actualFontSize forWidth:contentRect.size.width lineBreakMode:self.lineBreakMode];
	} else {
		textRect.size = [self.text sizeWithFont:self.font constrainedToSize:contentRect.size lineBreakMode:self.lineBreakMode];
	}
	
	// Horizontal alignment.
	switch (self.textAlignment) {
		case NSTextAlignmentCenter:
			textRect.origin.x = floorf(contentRect.origin.x + (contentRect.size.width - textRect.size.width) / 2.0f);
			break;
			
		case NSTextAlignmentRight:
			textRect.origin.x = floorf(contentRect.origin.x + contentRect.size.width - textRect.size.width);
			break;
			
		default:
			textRect.origin.x = floorf(contentRect.origin.x);
			break;
	}
	
	// Vertical alignment.
	switch (self.contentMode) {
		case UIViewContentModeTop:
		case UIViewContentModeTopLeft:
		case UIViewContentModeTopRight:
			textRect.origin.y = floorf(contentRect.origin.y);
			break;
			
		case UIViewContentModeBottom:
		case UIViewContentModeBottomLeft:
		case UIViewContentModeBottomRight:
			textRect.origin.y = floorf(contentRect.origin.y + contentRect.size.height - textRect.size.height);
			break;
			
		default:
			textRect.origin.y = floorf(contentRect.origin.y + floorf((contentRect.size.height - textRect.size.height) / 2.0f));
			break;
	}
	
	return textRect;
}

#pragma mark -

- (void)setDefaults {
	self.gradientStartPoint = CGPointMake(0.5f, 0.2f);
	self.gradientEndPoint = CGPointMake(0.5f, 0.8f);
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		self.backgroundColor = [UIColor clearColor];
		
		[self setDefaults];
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	
	if (self) {
		[self setDefaults];
	}
	
	return self;
}

@end
