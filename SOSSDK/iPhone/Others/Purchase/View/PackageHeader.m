//
//  PackageHeader.m
//  Onstar
//
//  Created by Joshua on 5/28/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import "PackageHeader.h"

@implementation PackageHeader

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier     {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib     {
    // Initialization code
     [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated     {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setPackage:(PackageInfos *)package withBlock:(CallBackBlock)block     {
    self.currentPackage = package;
    selectedBlock = [block copy];
}

#pragma mark - UI Action
- (IBAction)radioButtonClicked:(id)sender     {
    if (![self.radioButton isSelected]) {
        [_radioButton setSelected:YES];
        if (selectedBlock) {
            selectedBlock(self.currentPackage);
        }
    }
}

- (void)checkRadio:(BOOL)radioflag     {
    [self.radioButton setSelected:radioflag];
}

- (void)updateIndicator:(BOOL)indicatorFlag     {
    [self.expandIndicator setSelected:indicatorFlag];
}

@end
