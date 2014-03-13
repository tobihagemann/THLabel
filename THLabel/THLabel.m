//
//  THLabel.m
//
//  Version 1.3.1
//
//  Created by Tobias Hagemann on 11/25/12.
//  Copyright (c) 2014 tobiha.de. All rights reserved.
//
//  Original source and inspiration from:
//  FXLabel by Nick Lockwood,
//  https://github.com/nicklockwood/FXLabel
//  KSLabel by Kai Schweiger,
//  https://github.com/vigorouscoding/KSLabel
//  GTMFadeTruncatingLabel by Google,
//  https://code.google.com/p/google-toolbox-for-mac/source/browse/trunk/iPhone/
//
//  Big thanks to Jason Miller for showing me sample code of his implementation
//  using Core Text! It inspired me to dig deeper and move away from drawing
//  with NSAttributedString on iOS 7, which caused a lot of problems.
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


#import <Availability.h>
#if !__has_feature(objc_arc)
#error This class requires automatic reference counting.
#endif


#import <CoreText/CoreText.h>

#import "THLabel.h"

@implementation THLabel

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor clearColor];
		[self setDefaults];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		[self setDefaults];
	}
	return self;
}

- (void)setDefaults {
	self.gradientStartPoint = CGPointMake(0.5, 0.2);
	self.gradientEndPoint = CGPointMake(0.5, 0.8);
}

#pragma mark - Accessors and Mutators

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

- (CGFloat)strokeSizeDependentOnStrokePosition {
	switch (self.strokePosition) {
		case THLabelStrokePositionCenter:
			return self.strokeSize;
			
		default:
			// Stroke width times 2, because CG draws a centered stroke. We cut the rest into halves.
			return self.strokeSize * 2.0;
	}
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
	// Don't draw anything, if there is no text.
	if (!self.text || [self.text isEqualToString:@""]) {
		return;
	}
	
	// -------
	// Determine what has to be drawn.
	// -------
	
	BOOL hasShadow = self.shadowColor && ![self.shadowColor isEqual:[UIColor clearColor]] && (self.shadowBlur > 0.0 || !CGSizeEqualToSize(self.shadowOffset, CGSizeZero));
	BOOL hasInnerShadow = self.innerShadowColor && ![self.innerShadowColor isEqual:[UIColor clearColor]] && (self.innerShadowBlur > 0.0 || !CGSizeEqualToSize(self.innerShadowOffset, CGSizeZero));
	BOOL hasStroke = self.strokeSize > 0.0 && ![self.strokeColor isEqual:[UIColor clearColor]];
	BOOL hasGradient = [self.gradientColors count] > 1;
	BOOL hasFadeTruncating = self.fadeTruncatingMode != THLabelFadeTruncatingModeNone;
	BOOL needsMask = hasGradient || (hasStroke && self.strokePosition == THLabelStrokePositionInside) || hasInnerShadow;
	
	// -------
	// Step 1: Begin new drawing context, where we will apply all our styles.
	// -------
	
	UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGImageRef alphaMask = NULL;
	CGRect textRect;
	CTFrameRef frameRef = [self setupFrameForDrawingOutTextRect:&textRect];
	
	// Invert everything, because CG works with an inverted coordinate system.
	CGContextTranslateCTM(context, 0.0, CGRectGetHeight(rect));
	CGContextScaleCTM(context, 1.0, -1.0);
	
	// -------
	// Step 2: Prepare mask.
	// -------
	
	if (needsMask) {
		CGContextSaveGState(context);
		
		// Draw alpha mask.
		if (hasStroke) {
			// Text needs invisible stroke for consistent character glyph widths.
			CGContextSetTextDrawingMode(context, kCGTextFillStroke);
			CGContextSetLineWidth(context, [self strokeSizeDependentOnStrokePosition]);
			CGContextSetLineJoin(context, kCGLineJoinRound);
			[[UIColor clearColor] setStroke];
		} else {
			CGContextSetTextDrawingMode(context, kCGTextFill);
		}
		
		[[UIColor whiteColor] setFill];
		CTFrameDraw(frameRef, context);
		
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
		// Draw text.
		if (hasStroke) {
			// Text needs invisible stroke for consistent character glyph widths.
			CGContextSetTextDrawingMode(context, kCGTextFillStroke);
			CGContextSetLineWidth(context, [self strokeSizeDependentOnStrokePosition]);
			CGContextSetLineJoin(context, kCGLineJoinRound);
			[[UIColor clearColor] setStroke];
		} else {
			CGContextSetTextDrawingMode(context, kCGTextFill);
		}
		
		CTFrameDraw(frameRef, context);
	} else {
		// Clip the current context to alpha mask.
		CGContextClipToMask(context, rect, alphaMask);
		
		// Invert back to draw the gradient correctly.
		CGContextTranslateCTM(context, 0.0, CGRectGetHeight(rect));
		CGContextScaleCTM(context, 1.0, -1.0);
		
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
		
		// Clean up.
		CGColorSpaceRelease(colorSpace);
		CGGradientRelease(gradient);
	}
	
	CGContextRestoreGState(context);
	
	// -------
	// Step 4: Draw inner shadow.
	// -------
	
	if (hasInnerShadow) {
		CGContextSaveGState(context);
		
		// Clip the current context to alpha mask.
		CGContextClipToMask(context, rect, alphaMask);
		
		// Invert to draw the inner shadow correctly.
		CGContextTranslateCTM(context, 0.0, CGRectGetHeight(rect));
		CGContextScaleCTM(context, 1.0, -1.0);

		// Draw inner shadow.
		CGImageRef shadowImage = [self inverseMaskFromAlphaMask:alphaMask withRect:rect];
		CGContextSetShadowWithColor(context, self.innerShadowOffset, self.innerShadowBlur, self.innerShadowColor.CGColor);
		CGContextSetBlendMode(context, kCGBlendModeDarken);
		CGContextDrawImage(context, rect, shadowImage);
		
		// Clean up.
		CGImageRelease(shadowImage);
		
		CGContextRestoreGState(context);
	}

	// -------
	// Step 5: Draw stroke.
	// -------
	
	if (hasStroke) {
		CGContextSaveGState(context);
		
		CGContextSetTextDrawingMode(context, kCGTextStroke);
		
		CGImageRef image = NULL;
		
		if (self.strokePosition == THLabelStrokePositionOutside) {
			// Create an image from the text.
			image = CGBitmapContextCreateImage(context);
		} else if (self.strokePosition == THLabelStrokePositionInside) {
			// Clip the current context to alpha mask.
			CGContextClipToMask(context, rect, alphaMask);
		}
		
		// Draw stroke.
		CGImageRef strokeImage = [self strokeImageWithRect:rect frameRef:frameRef strokeSize:[self strokeSizeDependentOnStrokePosition] strokeColor:self.strokeColor];
		CGContextDrawImage(context, rect, strokeImage);
		
		if (self.strokePosition == THLabelStrokePositionOutside) {
			// Draw the saved image over half of the stroke.
			CGContextDrawImage(context, rect, image);
		}
		
		// Clean up.
		CGImageRelease(strokeImage);
		CGImageRelease(image);
		
		CGContextRestoreGState(context);
	}
	
	// -------
	// Step 6: Draw shadow.
	// -------
	
	if (hasShadow) {
		CGContextSaveGState(context);
		
		// Create an image from the text.
		CGImageRef image = CGBitmapContextCreateImage(context);
		
		// Clear the content.
		CGContextClearRect(context, rect);
		
		// Set shadow attributes.
		CGContextSetShadowWithColor(context, self.shadowOffset, self.shadowBlur, self.shadowColor.CGColor);
		
		// Draw the saved image, which throws off a shadow.
		CGContextDrawImage(context, rect, image);
		
		// Clean up.
		CGImageRelease(image);
		
		CGContextRestoreGState(context);
	}
	
	// -------
	// Step 7: Draw fade truncating.
	// -------
	
	if (hasFadeTruncating) {
		CGContextSaveGState(context);
		
		// Create an image from the text.
		CGImageRef image = CGBitmapContextCreateImage(context);
		
		// Clear the content.
		CGContextClearRect(context, rect);
		
		// Clip the current context to linear gradient mask.
		CGImageRef linearGradientImage = [self linearGradientImageWithRect:rect fadeHead:self.fadeTruncatingMode & THLabelFadeTruncatingModeHead fadeTail:self.fadeTruncatingMode & THLabelFadeTruncatingModeTail];
		CGContextClipToMask(context, self.bounds, linearGradientImage);
		
		// Draw the saved image, which is clipped by the linear gradient mask.
		CGContextDrawImage(context, rect, image);
		
		// Clean up.
		CGImageRelease(linearGradientImage);
		CGImageRelease(image);
		
		CGContextRestoreGState(context);
	}
	
	// -------
	// Step 8: End drawing context and finally draw the text with all styles.
	// -------
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	[image drawInRect:rect];
	
	// -------
	// Clean up.
	// -------
	
	if (needsMask) {
		CGImageRelease(alphaMask);
	}
	
	CFRelease(frameRef);
}

- (CTFrameRef)setupFrameForDrawingOutTextRect:(CGRect *)textRect {
	// Set up font.
	CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)self.font.fontName, self.font.pointSize, NULL);
	CTTextAlignment alignment = NSTextAlignmentToCTTextAlignment ? NSTextAlignmentToCTTextAlignment(self.textAlignment) : [self CTTextAlignmentFromNSTextAlignment:self.textAlignment];
	CTLineBreakMode lineBreakMode = (CTLineBreakMode)self.lineBreakMode;
	CTParagraphStyleSetting paragraphStyleSettings[] = {
		{kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &alignment},
		{kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &lineBreakMode}
	};
	CTParagraphStyleRef paragraphStyleRef = CTParagraphStyleCreate(paragraphStyleSettings, 2);
	
	// Set up attributed string.
	CFStringRef keys[] = {kCTFontAttributeName, kCTParagraphStyleAttributeName, kCTForegroundColorAttributeName};
	CFTypeRef values[] = {fontRef, paragraphStyleRef, self.textColor.CGColor};
	CFDictionaryRef attributes = CFDictionaryCreate(kCFAllocatorDefault, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	CFRelease(fontRef);
	CFRelease(paragraphStyleRef);
	
	CFStringRef stringRef = (__bridge CFStringRef)self.text;
	CFAttributedStringRef attributedStringRef = CFAttributedStringCreate(kCFAllocatorDefault, stringRef, attributes);
	CFRelease(attributes);
	
	// Set up frame.
	CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString(attributedStringRef);
	CFRelease(attributedStringRef);
	
	CGRect contentRect = [self contentRectFromBounds:self.bounds withInsets:self.textInsets];
	*textRect = [self textRectFromContentRect:contentRect framesetterRef:framesetterRef];
	CGMutablePathRef pathRef = CGPathCreateMutable();
	CGPathAddRect(pathRef, NULL, *textRect);
	
	CTFrameRef frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, [self.text length]), pathRef, NULL);
	CFRelease(framesetterRef);
	CGPathRelease(pathRef);
	return frameRef;
}

// Workaround for < iOS 6.
- (CTTextAlignment)CTTextAlignmentFromNSTextAlignment:(NSTextAlignment)nsTextAlignment {
	switch (nsTextAlignment) {
		case NSTextAlignmentLeft:
			return kCTTextAlignmentLeft;
		case NSTextAlignmentCenter:
			return kCTTextAlignmentCenter;
		case NSTextAlignmentRight:
			return kCTTextAlignmentRight;
		case NSTextAlignmentJustified:
			return kCTTextAlignmentJustified;
		case NSTextAlignmentNatural:
			return kCTTextAlignmentNatural;
		default:
			return 0;
	}
}

- (CGRect)contentRectFromBounds:(CGRect)bounds withInsets:(UIEdgeInsets)insets {
	CGRect contentRect = CGRectMake(0.0, 0.0, bounds.size.width, bounds.size.height);
	
	// Apply insets.
	contentRect.origin.x += insets.left;
	contentRect.origin.y += insets.top;
	contentRect.size.width -= insets.left + insets.right;
	contentRect.size.height -= insets.top + insets.bottom;
	
	return contentRect;
}

- (CGRect)textRectFromContentRect:(CGRect)contentRect framesetterRef:(CTFramesetterRef)framesetterRef {
	CGSize suggestedTextRectSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetterRef, CFRangeMake(0, [self.text length]), NULL, contentRect.size, NULL);
	if (CGSizeEqualToSize(suggestedTextRectSize, CGSizeZero)) {
		suggestedTextRectSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetterRef, CFRangeMake(0, [self.text length]), NULL, CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX), NULL);
	}
	CGRect textRect = CGRectMake(0.0, 0.0, suggestedTextRectSize.width, suggestedTextRectSize.height);
	
	// Horizontal alignment.
	switch (self.textAlignment) {
		case NSTextAlignmentCenter:
			textRect.origin.x = floorf(CGRectGetMinX(contentRect) + (CGRectGetWidth(contentRect) - CGRectGetWidth(textRect)) / 2.0);
			break;
			
		case NSTextAlignmentRight:
			textRect.origin.x = floorf(CGRectGetMinX(contentRect) + CGRectGetWidth(contentRect) - CGRectGetWidth(textRect));
			break;
			
		default:
			textRect.origin.x = floorf(CGRectGetMinX(contentRect));
			break;
	}
	
	// Vertical alignment. Top and bottom are upside down, because of inverted drawing.
	switch (self.contentMode) {
		case UIViewContentModeTop:
		case UIViewContentModeTopLeft:
		case UIViewContentModeTopRight:
			textRect.origin.y = floorf(CGRectGetMinY(contentRect) + CGRectGetHeight(contentRect) - CGRectGetHeight(textRect));
			break;
			
		case UIViewContentModeBottom:
		case UIViewContentModeBottomLeft:
		case UIViewContentModeBottomRight:
			textRect.origin.y = floorf(CGRectGetMinY(contentRect));
			break;
			
		default:
			textRect.origin.y = floorf(CGRectGetMinY(contentRect) + floorf((CGRectGetHeight(contentRect) - CGRectGetHeight(textRect)) / 2.0));
			break;
	}
	
	return textRect;
}

#pragma mark - Image Functions

- (CGImageRef)inverseMaskFromAlphaMask:(CGImageRef)alphaMask withRect:(CGRect)rect {
	// Create context.
	UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Fill rect, clip to alpha mask and clear.
	[[UIColor whiteColor] setFill];
	UIRectFill(rect);
	CGContextClipToMask(context, rect, alphaMask);
	CGContextClearRect(context, rect);
	
	// Return image.
	CGImageRef image = CGBitmapContextCreateImage(context);
	UIGraphicsEndImageContext();
	return image;
}

- (CGImageRef)strokeImageWithRect:(CGRect)rect frameRef:(CTFrameRef)frameRef strokeSize:(CGFloat)strokeSize strokeColor:(UIColor *)strokeColor {
	// Create context.
	UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetTextDrawingMode(context, kCGTextStroke);
	
	// Draw clipping mask.
	CGContextSetLineWidth(context, strokeSize);
	CGContextSetLineJoin(context, kCGLineJoinRound);
	[[UIColor whiteColor] setStroke];
	CTFrameDraw(frameRef, context);
	
	// Save clipping mask.
	CGImageRef clippingMask = CGBitmapContextCreateImage(context);
	
	// Clear the content.
	CGContextClearRect(context, rect);
	
	// Draw stroke.
	CGContextClipToMask(context, rect, clippingMask);
	CGContextTranslateCTM(context, 0.0, CGRectGetHeight(rect));
	CGContextScaleCTM(context, 1.0, -1.0);
	[strokeColor setFill];
	UIRectFill(rect);
	
	// Clean up and return image.
	CGImageRelease(clippingMask);
	CGImageRef image = CGBitmapContextCreateImage(context);
	UIGraphicsEndImageContext();
	return image;
}

- (CGImageRef)linearGradientImageWithRect:(CGRect)rect fadeHead:(BOOL)fadeHead fadeTail:(BOOL)fadeTail {
	// Create an opaque context.
	UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0.0);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// White background will mask opaque, black gradient will mask transparent.
	[[UIColor whiteColor] setFill];
	UIRectFill(rect);
	
	// Create gradient from white to black.
	CGFloat locs[2] = {0.0, 1.0};
	CGFloat components[4] = {1.0, 1.0, 0.0, 1.0};
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locs, 2);
	
	// Draw head and/or tail gradient.
	CGFloat fadeWidth = MIN(CGRectGetHeight(rect) * 2.0, floor(CGRectGetWidth(rect) / 4.0));
	CGFloat minX = CGRectGetMinX(rect);
	CGFloat maxX = CGRectGetMaxX(rect);
	if (fadeTail) {
		CGFloat startX = maxX - fadeWidth;
		CGPoint startPoint = CGPointMake(startX, CGRectGetMidY(rect));
		CGPoint endPoint = CGPointMake(maxX, CGRectGetMidY(rect));
		CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	}
	if (fadeHead) {
		CGFloat startX = minX + fadeWidth;
		CGPoint startPoint = CGPointMake(startX, CGRectGetMidY(rect));
		CGPoint endPoint = CGPointMake(minX, CGRectGetMidY(rect));
		CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	}
	
	// Clean up and return image.
	CGColorSpaceRelease(colorSpace);
	CGGradientRelease(gradient);
	CGImageRef image = CGBitmapContextCreateImage(context);
	UIGraphicsEndImageContext();
	return image;
}

@end
