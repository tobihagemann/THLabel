//
//  ViewController.m
//  THLabelExample
//
//  Created by Tobias Hagemann on 12/20/12.
//  Copyright (c) 2012 tobiha.de. All rights reserved.
//

#import "ViewController.h"
#import "THLabel.h"

#define kShadowColor1		[UIColor blackColor]
#define kShadowColor2		[UIColor colorWithWhite:0.0 alpha:0.75]
#define kShadowOffset1		CGSizeMake(0.0, UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 4.0 : 2.0)
#define kShadowOffset2		CGSizeMake(0.0, UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 2.0 : 1.0)
#define kShadowBlur1		(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 10.0 : 5.0)
#define kShadowBlur2		(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 4.0 : 2.0)

#define kStrokeColor		[UIColor blackColor]
#define kStrokeSize			(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 6.0 : 3.0)

#define kGradientStartColor	[UIColor colorWithRed:255.0 / 255.0 green:193.0 / 255.0 blue:127.0 / 255.0 alpha:1.0]
#define kGradientEndColor	[UIColor colorWithRed:255.0 / 255.0 green:163.0 / 255.0 blue:64.0 / 255.0 alpha:1.0]

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
	self.label1.shadowOffset = kShadowOffset1;
	self.label1.shadowBlur = kShadowBlur1;
	
	// Demonstrate inner shadow.
	self.label2.innerShadowColor = kShadowColor1;
	self.label2.innerShadowOffset = kShadowOffset2;
	self.label2.innerShadowBlur = kShadowBlur2;
	
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
	self.label6.shadowOffset = kShadowOffset1;
	self.label6.shadowBlur = kShadowBlur1;
	self.label6.innerShadowColor = kShadowColor2;
	self.label6.innerShadowOffset = kShadowOffset2;
	self.label6.innerShadowBlur = kShadowBlur2;
	self.label6.strokeColor = kStrokeColor;
	self.label6.strokeSize = kStrokeSize;
	self.label6.gradientStartColor = kGradientStartColor;
	self.label6.gradientEndColor = kGradientEndColor;
}

@end
