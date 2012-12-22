//
//  ViewController.m
//  THLabelExample
//
//  Created by Tobias Hagemann on 12/20/12.
//  Copyright (c) 2012 tobiha.de. All rights reserved.
//

#import "ViewController.h"
#import "THLabel.h"

#define kShadowOffsetY (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 4.0f : 2.0f)
#define kShadowBlur (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 10.0f : 5.0f)
#define kStrokeSize (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 6.0f : 3.0f)

@interface ViewController ()

@property (nonatomic, weak) IBOutlet THLabel *label1;
@property (nonatomic, weak) IBOutlet THLabel *label2;
@property (nonatomic, weak) IBOutlet THLabel *label3;
@property (nonatomic, weak) IBOutlet THLabel *label4;

@end

@implementation ViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// Demonstrate shadow blur.
	[self.label1 setShadowColor:[UIColor blackColor]];
	[self.label1 setShadowOffset:CGSizeMake(0.0f, kShadowOffsetY)];
	[self.label1 setShadowBlur:kShadowBlur];
	
	// Demonstrate stroke.
	[self.label2 setStrokeColor:[UIColor blackColor]];
	[self.label2 setStrokeSize:kStrokeSize];
	
	// Demonstrate fill gradient.
	[self.label3 setGradientStartColor:[UIColor colorWithRed:255.0f / 255.0f green:193.0f / 255.0f blue:127.0f / 255.0f alpha:1.0f]];
	[self.label3 setGradientEndColor:[UIColor colorWithRed:255.0f / 255.0f green:163.0f / 255.0f blue:64.0f / 255.0f alpha:1.0f]];
	
	// Demonstrate everything.
	[self.label4 setShadowColor:[UIColor colorWithWhite:0.0f alpha:0.75f]];
	[self.label4 setShadowOffset:CGSizeMake(0.0f, kShadowOffsetY)];
	[self.label4 setShadowBlur:kShadowBlur];
	[self.label4 setStrokeColor:[UIColor blackColor]];
	[self.label4 setStrokeSize:kStrokeSize];
	[self.label4 setGradientStartColor:[UIColor colorWithRed:255.0f / 255.0f green:193.0f / 255.0f blue:127.0f / 255.0f alpha:1.0f]];
	[self.label4 setGradientEndColor:[UIColor colorWithRed:255.0f / 255.0f green:163.0f / 255.0f blue:64.0f / 255.0f alpha:1.0f]];
}

@end
