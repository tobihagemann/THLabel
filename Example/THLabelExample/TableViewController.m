//
//  TableViewController.m
//  THLabelExample
//
//  Created by Tobias Hagemann on 09/09/14.
//  Copyright (c) 2014 tobiha.de. All rights reserved.
//

#import "TableViewController.h"
#import "THLabel.h"

@interface TableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet THLabel *customTextLabel;
@end

@implementation TableViewCell
@end

@implementation TableViewController

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
	cell.customTextLabel.textColor = [UIColor whiteColor];
	cell.customTextLabel.strokeColor = kStrokeColor;
	cell.customTextLabel.strokeSize = kStrokeSize;
	cell.customTextLabel.gradientStartColor = kGradientStartColor;
	cell.customTextLabel.gradientEndColor = kGradientEndColor;
	return cell;
}

@end
