//
//  ViewController.m
//  THLabelExample
//
//  Created by Tobias Hagemann on 12/20/12.
//  Copyright (c) 2012 tobiha.de. All rights reserved.
//

#import "ViewController.h"
#import "THLabel.h"

@interface ViewController ()
@property (nonatomic, weak) IBOutlet THLabel *label1;
@property (nonatomic, weak) IBOutlet THLabel *label2;
@property (nonatomic, weak) IBOutlet THLabel *label3;
@property (nonatomic, weak) IBOutlet THLabel *label4;
@property (nonatomic, weak) IBOutlet THLabel *label5;
@property (nonatomic, weak) IBOutlet THLabel *label6;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Demonstrate shadow blur.
	self.label1.shadowColor = kShadowColor1;
	self.label1.shadowOffset = kShadowOffset;
	self.label1.shadowBlur = kShadowBlur;
	
	// Demonstrate inner shadow.
	self.label2.innerShadowColor = kShadowColor1;
	self.label2.innerShadowOffset = kInnerShadowOffset;
	self.label2.innerShadowBlur = kInnerShadowBlur;
	
	// Demonstrate stroke.
	self.label3.strokeColor = kStrokeColor;
	self.label3.strokeSize = kStrokeSize;
	
	// Demonstrate fill gradient.
	self.label4.gradientStartColor = kGradientStartColor;
	self.label4.gradientEndColor = kGradientEndColor;
	
	// Demonstrate fade truncating.
	self.label5.fadeTruncatingMode = THLabelFadeTruncatingModeTail;
	
	// Demonstrate everything.
	self.label6.shadowColor = kShadowColor2;
	self.label6.shadowOffset = kShadowOffset;
	self.label6.shadowBlur = kShadowBlur;
	self.label6.innerShadowColor = kShadowColor2;
	self.label6.innerShadowOffset = kInnerShadowOffset;
	self.label6.innerShadowBlur = kInnerShadowBlur;
	self.label6.strokeColor = kStrokeColor;
	self.label6.strokeSize = kStrokeSize;
	self.label6.gradientStartColor = kGradientStartColor;
	self.label6.gradientEndColor = kGradientEndColor;
}

@end
