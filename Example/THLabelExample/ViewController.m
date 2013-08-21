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
#define kShadowOffset		CGSizeMake(0.0, UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 4.0 : 2.0)
#define kShadowBlur			(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 10.0 : 5.0)

#define kStrokeColor		[UIColor blackColor]
#define kStrokeSize			(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 6.0 : 3.0)

#define kGradientStartColor	[UIColor colorWithRed:255.0 / 255.0 green:193.0 / 255.0 blue:127.0 / 255.0 alpha:1.0]
#define kGradientEndColor	[UIColor colorWithRed:255.0 / 255.0 green:163.0 / 255.0 blue:64.0 / 255.0 alpha:1.0]

@interface ViewController ()
@property (nonatomic, weak) IBOutlet THLabel *label1;
@property (nonatomic, weak) IBOutlet THLabel *label2;
@property (nonatomic, weak) IBOutlet THLabel *label3;
@property (nonatomic, weak) IBOutlet THLabel *label4;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Demonstrate shadow blur.
	self.label1.shadowColor = kShadowColor1;
	self.label1.shadowOffset = kShadowOffset;
	self.label1.shadowBlur = kShadowBlur;
	
	// Demonstrate stroke.
	self.label2.strokeColor = kStrokeColor;
	self.label2.strokeSize = kStrokeSize;
	
	// Demonstrate fill gradient.
	self.label3.gradientStartColor = kGradientStartColor;
	self.label3.gradientEndColor = kGradientEndColor;
	
	// Demonstrate everything.
	self.label4.shadowColor = kShadowColor2;
	self.label4.shadowOffset = kShadowOffset;
	self.label4.shadowBlur = kShadowBlur;
	self.label4.strokeColor = kStrokeColor;
	self.label4.strokeSize = kStrokeSize;
	self.label4.gradientStartColor = kGradientStartColor;
	self.label4.gradientEndColor = kGradientEndColor;
}

@end
