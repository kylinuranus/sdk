//
//  OrderRecordHeader.m
//  Onstar
//
//  Created by Joshua on 6/9/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import "OrderRecordHeader.h"

@implementation OrderRecordHeader

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier     {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];

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

- (void)updateIndicator:(BOOL)indicatorFlag     {
    [self.expandIndicator setSelected:indicatorFlag];
    [self.seperatorLine setHidden:indicatorFlag];
}

@end
