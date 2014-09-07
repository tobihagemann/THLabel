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

#define kStrokeColor1		[UIColor colorWithRed:0.923 green:0.484 blue:0.134 alpha:1.000]
#define kStrokeSize1        (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 8.0 : 4.0)
#define kStrokeColor2		[UIColor colorWithRed:0.992 green:0.864 blue:0.367 alpha:1.000]
#define kStrokeSize2		(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 12.0 : 6.0)

#define kGradientStartColor	[UIColor colorWithRed:255.0 / 255.0 green:193.0 / 255.0 blue:127.0 / 255.0 alpha:1.0]
#define kGradientEndColor	[UIColor colorWithRed:255.0 / 255.0 green:163.0 / 255.0 blue:64.0 / 255.0 alpha:1.0]

@interface ViewController ()
@property (nonatomic, weak) IBOutlet THLabel *label1;
@property (nonatomic, weak) IBOutlet THLabel *label2;
@property (nonatomic, weak) IBOutlet THLabel *label3;
@property (nonatomic, weak) IBOutlet THLabel *label4;
@property (nonatomic, weak) IBOutlet THLabel *label5;
@property (nonatomic, weak) IBOutlet THLabel *label6;
@property (nonatomic, weak) IBOutlet THLabel *label7;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Demonstrate shadow blur.
	[self.label1 addShadow:[THLabelShadow newWithColor:kShadowColor1 blur:kShadowBlur1 offset:kShadowOffset1 type:THLabelShadowTypeOuter]];
    
	// Demonstrate inner shadow.
    [self.label2 addShadow:[THLabelShadow newWithColor:kShadowColor1 blur:kShadowBlur2 offset:kShadowOffset2 type:THLabelShadowTypeInner]];
	
	// Demonstrate stroke.
    [self.label3 addStroke:[THLabelStroke newWithColor:kStrokeColor1 size:kStrokeSize1 position:THLabelStrokePositionOutside]];
	// Demonstrate fill gradient.
	self.label4.gradientStartColor = kGradientStartColor;
	self.label4.gradientEndColor = kGradientEndColor;
	
	// Demonstrate fade truncating.
	self.label5.fadeTruncatingMode = THLabelFadeTruncatingModeTail;
	
	// Demonstrate everything.
    [self.label6 addShadow:[THLabelShadow newWithColor:kShadowColor2 blur:kShadowBlur1 offset:kShadowOffset1 type:THLabelShadowTypeOuter]];
    [self.label6 addShadow:[THLabelShadow newWithColor:kShadowColor2 blur:kShadowBlur2 offset:kShadowOffset2 type:THLabelShadowTypeInner]];
    
    [self.label6 addStroke:[THLabelStroke newWithColor:kStrokeColor1 size:kStrokeSize1 position:THLabelStrokePositionOutside]];
    
	self.label6.gradientStartColor = kGradientStartColor;
	self.label6.gradientEndColor = kGradientEndColor;
    
    [self.label7 addStroke:[THLabelStroke newWithColor:kStrokeColor1 size:kStrokeSize1 position:THLabelStrokePositionOutside]];
    [self.label7 addStroke:[THLabelStroke newWithColor:kStrokeColor2 size:kStrokeSize2 position:THLabelStrokePositionOutside]];
}

@end
