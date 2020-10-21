//
//  THLabel.swift
//
//  Version 1.4.8
//
//  Created by Vitalii Parovishnyk on 01/12/17.
//  Copyright (c) 2018 IGR Software. All rights reserved.
//
//  Original source and inspiration from:
//  FXLabel by Nick Lockwood,
//  https://github.com/nicklockwood/FXLabel
//  KSLabel by Kai Schweiger,
//  https://github.com/vigorouscoding/KSLabel
//  GTMFadeTruncatingLabel by Google,
//  https://github.com/google/google-toolbox-for-mac/tree/master/iPhone
//
//  Big thanks to Jason Miller for showing me sample code of his implementation
//  using Core Text! It inspired me to dig deeper and move away from drawing
//  with NSAttributedString on iOS 7, which caused a lot of problems.
//
//  Distributed under the permissive zlib license
//  Get the latest version from here:
//
//  https://github.com/tobihagemann/THLabel
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

import UIKit
import Foundation
import CoreFoundation
import CoreText
import CoreGraphics

public enum THLabelStrokePosition : Int {
    case outside
    case center
    case inside
}

public struct THLabelFadeTruncatingMode : OptionSet {
    public let rawValue: Int
    public init(rawValue:Int) { self.rawValue = rawValue}
    
    static let none = THLabelFadeTruncatingMode(rawValue: 0)
    static let tail = THLabelFadeTruncatingMode(rawValue: 1 << 0)
    static let head = THLabelFadeTruncatingMode(rawValue: 1 << 1)
    static let headAndTail : THLabelFadeTruncatingMode = [.tail, .head]
}

open
class THLabel: UILabel {
    
    // MARK: - Accessors and Mutators
    
    open var letterSpacing: CGFloat     = 0.0
    open var lineSpacing: CGFloat       = 0.0
    
    private var _shadowBlur: CGFloat    = 0.0
    open var shadowBlur: CGFloat {
        get {
            return _shadowBlur
        }
        set {
            _shadowBlur = CGFloat(fmaxf(Float(newValue), 0.0))
        }
    }
    
    open var innerShadowBlur: CGFloat   = 0.0
    open var innerShadowOffset: CGSize  = CGSize.zero
    open var innerShadowColor: UIColor!
    
    open var strokeSize: CGFloat                    = 0.0
    open var strokeColor: UIColor!
    open var strokePosition: THLabelStrokePosition  = THLabelStrokePosition.outside
    
    open var gradientStartColor: UIColor! {
        get {
            return self.gradientColors.count > 0 ? self.gradientColors.first! : nil
        }
        set {
            if newValue == nil {
                self.gradientColors = []
            }
            else if self.gradientColors.count < 2 {
                self.gradientColors = [newValue, newValue]
            }
            else if !self.gradientColors.first!.isEqual(newValue) {
                var colors = self.gradientColors
                colors[0] = newValue
                self.gradientColors = colors
            }
        }
    }
    
    open var gradientEndColor: UIColor! {
        get {
            return self.gradientColors.count > 0 ? self.gradientColors.last! : nil
        }
        set {
            if newValue == nil {
                self.gradientColors = []
            }
            else if self.gradientColors.count < 2 {
                self.gradientColors = [newValue, newValue]
            }
            else if !self.gradientColors.last!.isEqual(newValue) {
                var colors = self.gradientColors
                colors[colors.count - 1] = newValue
                self.gradientColors = colors
            }
        }
    }
    private var _gradientColors : [UIColor] = []
    open var gradientColors : [UIColor] {
        get {
            return _gradientColors
        }
        set {
            if _gradientColors != newValue {
                _gradientColors = newValue
                self.setNeedsDisplay()
            }
        }
    }
    
    open var gradientStartPoint: CGPoint    = CGPoint.zero
    open var gradientEndPoint: CGPoint      = CGPoint.zero
    
    open var fadeTruncatingMode: THLabelFadeTruncatingMode  = THLabelFadeTruncatingMode.none
    
    private var _textInsets : UIEdgeInsets  = UIEdgeInsets.zero
    open var textInsets : UIEdgeInsets {
        get {
            return _textInsets
        }
        set {
            if !UIEdgeInsetsEqualToEdgeInsets(_textInsets, newValue) {
                _textInsets = newValue
                self.setNeedsDisplay()
            }
        }
    }
    
    open var isAutomaticallyAdjustTextInsets: Bool = false
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        self.setDefaults()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setDefaults()
    }
    
    fileprivate func setDefaults() {
        self.clipsToBounds = true
        self.gradientStartPoint = CGPoint(x: CGFloat(0.5), y: CGFloat(0.2))
        self.gradientEndPoint = CGPoint(x: CGFloat(0.5), y: CGFloat(0.8))
        self.isAutomaticallyAdjustTextInsets = true
    }
    
    fileprivate func hasShadow() -> Bool {
        return self.shadowColor != nil && !self.shadowColor!.isEqual(UIColor.clear) && (self.shadowBlur > 0.0 || !self.shadowOffset.equalTo(CGSize.zero))
    }
    
    fileprivate func hasInnerShadow() -> Bool {
        return (self.innerShadowColor != nil) && !self.innerShadowColor.isEqual(UIColor.clear) && (self.innerShadowBlur > 0.0 || !self.innerShadowOffset.equalTo(CGSize.zero))
    }
    
    fileprivate func hasStroke() -> Bool {
        return self.strokeSize > 0.0 && !self.strokeColor.isEqual(UIColor.clear)
    }
    
    fileprivate func hasGradient() -> Bool {
        return self.gradientColors.count > 1
    }
    
    fileprivate func hasFadeTruncating() -> Bool {
        return self.fadeTruncatingMode != THLabelFadeTruncatingMode.none
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        return self.intrinsicContentSize
    }
    
    override open var intrinsicContentSize: CGSize {
        get {
            if self.text == nil || (self.text == "") {
                return CGSize.zero
            }
            let textRect = self.frameRef(from: CGSize(width: CGFloat(self.preferredMaxLayoutWidth), height: CGFloat.greatestFiniteMagnitude)).CGRect
            let newWidth = textRect.width + self.textInsets.left + self.textInsets.right
            let newHeight = textRect.height + self.textInsets.top + self.textInsets.bottom
            return CGSize(width: CGFloat(ceilf(Float(newWidth))), height: CGFloat(ceilf(Float(newHeight))))
        }
    }
    
    fileprivate func strokeSizeDependentOnStrokePosition() -> CGFloat {
        switch self.strokePosition {
        case .center:
            return self.strokeSize
        default:
            // Stroke width times 2, because CG draws a centered stroke. We cut the rest into halves.
            return self.strokeSize * 2.0
        }
    }
    
    // MARK: - Drawing
    
    override open func draw(_ rect: CGRect) {
        // Don't draw anything, if there is no text.
        if self.text == nil || (self.text == "") {
            return
        }
        // -------
        // Determine what has to be drawn.
        // -------
        let hasShadow = self.hasShadow()
        let hasInnerShadow = self.hasInnerShadow()
        let hasStroke = self.hasStroke()
        let hasGradient = self.hasGradient()
        let hasFadeTruncating = self.hasFadeTruncating()
        let needsMask = hasGradient || (hasStroke && self.strokePosition == .inside) || hasInnerShadow
        // -------
        // Step 1: Begin new drawing context, where we will apply all our styles.
        // -------
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()!
        var alphaMask: CGImage? = nil
        let frame = self.frameRef(from: self.bounds.size)
        let textRect = frame.CGRect
        let frameRef = frame.CTFrame
        // Invert everything, because CG works with an inverted coordinate system.
        context.translateBy(x: 0.0, y: rect.height)
        context.scaleBy(x: 1.0, y: -1.0)
        // -------
        // Step 2: Prepare mask.
        // -------
        if needsMask {
            context.saveGState()
            // Draw alpha mask.
            context.setTextDrawingMode(.fill)
            UIColor.white.setFill()
            CTFrameDraw(frameRef, context)
            // Save alpha mask.
            alphaMask = context.makeImage()
            // Clear the content.
            context.clear(rect)
            context.restoreGState()
        }
        // -------
        // Step 3: Draw text normally, or with gradient.
        // -------
        context.saveGState()
        if !hasGradient {
            // Draw text.
            context.setTextDrawingMode(.fill)
            CTFrameDraw(frameRef, context)
        }
        else {
            // Clip the current context to alpha mask.
            context.clip(to: rect, mask: alphaMask!)
            // Invert back to draw the gradient correctly.
            context.translateBy(x: 0.0, y: rect.height)
            context.scaleBy(x: 1.0, y: -1.0)
            // Get gradient colors as CGColor.
            var gradientColors = [CGColor]() /* capacity: self.gradientColors.count */
            for color: UIColor in self.gradientColors {
                gradientColors.append(color.cgColor)
            }
            // Create gradient.
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(colorsSpace: colorSpace, colors: (gradientColors as CFArray), locations: nil)
            let startPoint = CGPoint(x: CGFloat(textRect.origin.x + self.gradientStartPoint.x * textRect.width), y: CGFloat(textRect.origin.y + self.gradientStartPoint.y * textRect.height))
            let endPoint = CGPoint(x: CGFloat(textRect.origin.x + self.gradientEndPoint.x * textRect.width), y: CGFloat(textRect.origin.y + self.gradientEndPoint.y * textRect.height))
            // Draw gradient.
            context.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: [.drawsBeforeStartLocation , .drawsAfterEndLocation])
            // Clean up.
        }
        context.restoreGState()
        // -------
        // Step 4: Draw inner shadow.
        // -------
        if hasInnerShadow {
            context.saveGState()
            // Clip the current context to alpha mask.
            context.clip(to: rect, mask: alphaMask!)
            // Invert to draw the inner shadow correctly.
            context.translateBy(x: 0.0, y: rect.height)
            context.scaleBy(x: 1.0, y: -1.0)
            // Draw inner shadow.
            let shadowImage = self.inverseMask(fromAlphaMask: alphaMask!, with: rect)
            context.setShadow(offset: self.innerShadowOffset, blur: self.innerShadowBlur, color: self.innerShadowColor.cgColor)
            context.setBlendMode(.darken)
            context.draw(shadowImage, in: rect)
            // Clean up.
            context.restoreGState()
        }
        
        // -------
        // Step 5: Draw stroke.
        // -------
        if hasStroke {
            context.saveGState()
            context.setTextDrawingMode(.stroke)
            var image: CGImage? = nil
            if self.strokePosition == .outside {
                // Create an image from the text.
                image = context.makeImage()
            }
            else if self.strokePosition == .inside {
                // Clip the current context to alpha mask.
                context.clip(to: rect, mask: alphaMask!)
            }
            
            // Draw stroke.
            let strokeImage = self.strokeImage(with: rect, frameRef: frameRef, strokeSize: self.strokeSizeDependentOnStrokePosition(), stroke: self.strokeColor)
            context.draw(strokeImage, in: rect)
            if self.strokePosition == .outside {
                // Draw the saved image over half of the stroke.
                context.draw(image!, in: rect)
            }
            // Clean up.
            context.restoreGState()
        }
        
        // -------
        // Step 6: Draw shadow.
        // -------
        if hasShadow {
            context.saveGState()
            // Create an image from the text.
            let image = context.makeImage()
            // Clear the content.
            context.clear(rect)
            // Set shadow attributes.
            context.setShadow(offset: self.shadowOffset, blur: self.shadowBlur, color: self.shadowColor!.cgColor)
            // Draw the saved image, which throws off a shadow.
            context.draw(image!, in: rect)
            // Clean up.
            context.restoreGState()
        }
        
        // -------
        // Step 7: Draw fade truncating.
        // -------
        if hasFadeTruncating {
            context.saveGState()
            // Create an image from the text.
            let image = context.makeImage()
            // Clear the content.
            context.clear(rect)
            // Clip the current context to linear gradient mask.
            let linearGradientImage = self.linearGradientImage(with: rect, fadeHead: self.fadeTruncatingMode.contains(.head), fadeTail: self.fadeTruncatingMode.contains(.tail))
            context.clip(to: self.bounds, mask: linearGradientImage)
            // Draw the saved image, which is clipped by the linear gradient mask.
            context.draw(image!, in: rect)
            // Clean up.
            context.restoreGState()
        }
        
        // -------
        // Step 8: End drawing context and finally draw the text with all styles.
        // -------
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        image.draw(in: rect)
    }
    
    fileprivate func frameRef(from size: CGSize) -> (CTFrame: CTFrame, CGRect: CGRect) {
        // Set up font.
		let fontRef = CTFontCreateWithFontDescriptor((self.font.fontDescriptor as CTFontDescriptor), self.font.pointSize, nil)
        var alignment = CTTextAlignment(self.textAlignment)
        var lineBreakMode = CTLineBreakModeFromUILineBreakMode(self.lineBreakMode)
        var lineSpacing = self.lineSpacing
        let paragraphStyleSettings: [CTParagraphStyleSetting] = [
            CTParagraphStyleSetting(spec: .alignment, valueSize: MemoryLayout.size(ofValue: alignment), value: &alignment),
            CTParagraphStyleSetting(spec: .lineBreakMode, valueSize: MemoryLayout.size(ofValue: lineBreakMode), value: &lineBreakMode),
            CTParagraphStyleSetting(spec: .lineSpacingAdjustment, valueSize: MemoryLayout.size(ofValue: lineSpacing), value: &lineSpacing)
            ]
        
        let paragraphStyleRef = CTParagraphStyleCreate(paragraphStyleSettings, paragraphStyleSettings.count)
        let kernRef = CFNumberCreate(kCFAllocatorDefault, .cgFloatType, &letterSpacing)
        // Set up attributed string.
        let keys: [String] = [kCTFontAttributeName as String, kCTParagraphStyleAttributeName as String, kCTForegroundColorAttributeName as String, kCTKernAttributeName as String]
        let values: [CFTypeRef] = [fontRef, paragraphStyleRef, self.textColor.cgColor, kernRef!]
        
        let attributes = NSDictionary(objects: values, forKeys: keys as [NSCopying])
        let stringRef = (self.text! as CFString)
        let attributedStringRef = CFAttributedStringCreate(kCFAllocatorDefault, stringRef, attributes as CFDictionary)
        // Set up frame.
        let framesetterRef = CTFramesetterCreateWithAttributedString(attributedStringRef!)
        if self.isAutomaticallyAdjustTextInsets {
            self.textInsets = self.fittingTextInsets()
        }
        
        let contentRect = self.contentRect(from: size, with: self.textInsets)
        let textRect = self.textRect(fromContentRect: contentRect, framesetterRef: framesetterRef)
        let pathRef = CGMutablePath()
        pathRef.addRect(textRect, transform: .identity)
        let frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, (self.text?.count)!), pathRef, nil)
        
        return (frameRef, textRect)
    }
    
    fileprivate func contentRect(from size: CGSize, with insets: UIEdgeInsets) -> CGRect {
        var contentRect = CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: CGFloat(size.width), height: CGFloat(size.height))
        // Apply insets.
        contentRect.origin.x += insets.left
        contentRect.origin.y += insets.top
        contentRect.size.width -= insets.left + insets.right
        contentRect.size.height -= insets.top + insets.bottom
        return contentRect
    }
    
    fileprivate func textRect(fromContentRect contentRect: CGRect, framesetterRef: CTFramesetter) -> CGRect {
        var suggestedTextRectSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetterRef, CFRangeMake(0, (self.text?.count)!), nil, contentRect.size, nil)
        if suggestedTextRectSize.equalTo(CGSize.zero) {
            suggestedTextRectSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetterRef, CFRangeMake(0, (self.text?.count)!), nil, CGSize(width: CGFloat(CGFloat.greatestFiniteMagnitude), height: CGFloat(CGFloat.greatestFiniteMagnitude)), nil)
        }
        var textRect = CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: CGFloat(ceilf(Float(suggestedTextRectSize.width))), height: CGFloat(ceilf(Float(suggestedTextRectSize.height))))
        // Horizontal alignment.
        switch self.textAlignment {
        case .center:
            textRect.origin.x = CGFloat(floorf(Float(contentRect.minX + (contentRect.width - textRect.width) / 2.0)))
        case .right:
            textRect.origin.x = CGFloat(floorf(Float(contentRect.minX + contentRect.width - textRect.width)))
        default:
            textRect.origin.x = CGFloat(floorf(Float(contentRect.minX)))
        }
        
        // Vertical alignment. Top and bottom are upside down, because of inverted drawing.
        switch self.contentMode {
        case .top, .topLeft, .topRight:
            textRect.origin.y = CGFloat(floorf(Float(contentRect.minY + contentRect.height - textRect.height)))
        case .bottom, .bottomLeft, .bottomRight:
            textRect.origin.y = CGFloat(floorf(Float(contentRect.minY)))
        default:
            textRect.origin.y = CGFloat(floorf(Float(contentRect.minY) + floorf(Float((contentRect.height - textRect.height)) / 2.0)))
        }
        
        return textRect
    }
    
    fileprivate func fittingTextInsets() -> UIEdgeInsets {
        let hasShadow = self.hasShadow()
        let hasStroke = self.hasStroke()
        var edgeInsets = UIEdgeInsets.zero
        if hasStroke {
            switch self.strokePosition {
            case .outside:
                edgeInsets = UIEdgeInsets(top: self.strokeSize, left: self.strokeSize, bottom: self.strokeSize, right: self.strokeSize)
            case .inside:
                edgeInsets = UIEdgeInsets(top: self.strokeSize / 2.0, left: self.strokeSize / 2.0, bottom: self.strokeSize / 2.0, right: self.strokeSize / 2.0)
            default:
                break
            }
        }
        if hasShadow {
            edgeInsets.top = CGFloat(fmaxf(Float(edgeInsets.top + self.shadowBlur + self.shadowOffset.height), Float(edgeInsets.top)))
            edgeInsets.left = CGFloat(fmaxf(Float(edgeInsets.left + self.shadowBlur + self.shadowOffset.width), Float(edgeInsets.left)))
            edgeInsets.bottom = CGFloat(fmaxf(Float(edgeInsets.bottom + self.shadowBlur - self.shadowOffset.height), Float(edgeInsets.bottom)))
            edgeInsets.right = CGFloat(fmaxf(Float(edgeInsets.right + self.shadowBlur - self.shadowOffset.width), Float(edgeInsets.right)))
        }
        
        return edgeInsets
    }
    
    // MARK: - Image Functions
    
    fileprivate func inverseMask(fromAlphaMask alphaMask: CGImage, with rect: CGRect) -> CGImage {
        // Create context.
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()!
        // Fill rect, clip to alpha mask and clear.
        UIColor.white.setFill()
        UIRectFill(rect)
        context.clip(to: rect, mask: alphaMask)
        context.clear(rect)
        // Return image.
        let image = context.makeImage()
        UIGraphicsEndImageContext()
        return image!
    }
    
    fileprivate func strokeImage(with rect: CGRect, frameRef: CTFrame, strokeSize: CGFloat, stroke strokeColor: UIColor) -> CGImage {
        // Create context.
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()!
        context.setTextDrawingMode(.stroke)
        // Draw clipping mask.
        context.setLineWidth(strokeSize)
        context.setLineJoin(.round)
        UIColor.white.setStroke()
        CTFrameDraw(frameRef, context)
        // Save clipping mask.
        let clippingMask = context.makeImage()
        // Clear the content.
        context.clear(rect)
        // Draw stroke.
        context.clip(to: rect, mask: clippingMask!)
        context.translateBy(x: 0.0, y: rect.height)
        context.scaleBy(x: 1.0, y: -1.0)
        strokeColor.setFill()
        UIRectFill(rect)
        // Clean up and return image.
        let image = context.makeImage()
        UIGraphicsEndImageContext()
        return image!
    }
    
    fileprivate func linearGradientImage(with rect: CGRect, fadeHead: Bool, fadeTail: Bool) -> CGImage {
        // Create an opaque context.
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0.0)
        let context = UIGraphicsGetCurrentContext()!
        // White background will mask opaque, black gradient will mask transparent.
        UIColor.white.setFill()
        UIRectFill(rect)
        // Create gradient from white to black.
        let locs : [CGFloat] = [0.0, 1.0]
        let components : [CGFloat] = [1.0, 1.0, 0.0, 1.0]
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: locs, count: 2)!
        // Draw head and/or tail gradient.
        let fadeWidth: CGFloat = CGFloat(fminf(Float(rect.height * 2.0), floorf(Float(rect.width / 4.0))))
        let minX: CGFloat = rect.minX
        let maxX: CGFloat = rect.maxX
        if fadeTail {
            let startX: CGFloat = maxX - fadeWidth
            let startPoint = CGPoint(x: startX, y: CGFloat(rect.midY))
            let endPoint = CGPoint(x: maxX, y: CGFloat(rect.midY))
            context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
        }
        if fadeHead {
            let startX: CGFloat = minX + fadeWidth
            let startPoint = CGPoint(x: startX, y: CGFloat(rect.midY))
            let endPoint = CGPoint(x: minX, y: CGFloat(rect.midY))
            context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
        }
        // Clean up and return image.
        
        let image = context.makeImage()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    func CTLineBreakModeFromUILineBreakMode(_ lineBreakMode: NSLineBreakMode) -> CTLineBreakMode {
        switch (lineBreakMode) {
        case .byWordWrapping: return .byWordWrapping;
        case .byCharWrapping: return .byCharWrapping;
        case .byClipping: return .byClipping;
        case .byTruncatingHead: return .byTruncatingHead;
        case .byTruncatingTail: return .byTruncatingTail;
        case .byTruncatingMiddle: return .byTruncatingMiddle;
        }
    }
}

