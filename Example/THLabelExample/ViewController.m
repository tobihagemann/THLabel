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
#define kShadowColor2		[UIColor colorWithWhite:0.0f alpha:0.75f]
#define kShadowOffset		CGSizeMake(0.0f, UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 4.0f : 2.0f)
#define kShadowBlur			(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 10.0f : 5.0f)

#define kStrokeColor		[UIColor blackColor]
#define kStrokeSize			(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 6.0f : 3.0f)

#define kGradientStartColor	[UIColor colorWithRed:255.0f / 255.0f green:193.0f / 255.0f blue:127.0f / 255.0f alpha:1.0f]
#define kGradientEndColor	[UIColor colorWithRed:255.0f / 255.0f green:163.0f / 255.0f blue:64.0f / 255.0f alpha:1.0f]

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
