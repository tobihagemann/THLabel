//
//  THLabel.h
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

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, THLabelStrokePosition) {
	THLabelStrokePositionOutside,
	THLabelStrokePositionCenter,
	THLabelStrokePositionInside
};

typedef NS_OPTIONS(NSUInteger, THLabelFadeTruncatingMode) {
	THLabelFadeTruncatingModeNone = 0,
	THLabelFadeTruncatingModeTail = 1 << 0,
	THLabelFadeTruncatingModeHead = 1 << 1,
	THLabelFadeTruncatingModeHeadAndTail = THLabelFadeTruncatingModeHead | THLabelFadeTruncatingModeTail
};

@interface THLabel : UILabel

@property (nonatomic, assign) CGFloat shadowBlur;

@property (nonatomic, assign) CGFloat innerShadowBlur;
@property (nonatomic, assign) CGSize innerShadowOffset;
@property (nonatomic, strong) UIColor *innerShadowColor;

@property (nonatomic, assign) CGFloat strokeSize;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, assign) THLabelStrokePosition strokePosition;

@property (nonatomic, strong) UIColor *gradientStartColor;
@property (nonatomic, strong) UIColor *gradientEndColor;
@property (nonatomic, copy) NSArray *gradientColors;
@property (nonatomic, assign) CGPoint gradientStartPoint;
@property (nonatomic, assign) CGPoint gradientEndPoint;

@property (nonatomic, assign) THLabelFadeTruncatingMode fadeTruncatingMode;

@property (nonatomic, assign) UIEdgeInsets textInsets;

@end
