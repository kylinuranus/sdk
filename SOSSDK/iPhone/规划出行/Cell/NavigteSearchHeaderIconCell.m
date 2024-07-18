//
//  NavigteSearchHeaderIconCell.m
//  Onstar
//
//  Created by Coir on 16/1/22.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "CustomerInfo.h"
#import "SOSAroundSearchVC.h"
#import "NavigteSearchHeaderIconCell.h"

@interface NavigteSearchHeaderIconCell ()   {
}

@end

@implementation NavigteSearchHeaderIconCell

- (void)awakeFromNib    {
    [super awakeFromNib];
    if (SCREEN_WIDTH == 320) {
        self.title.font = [UIFont systemFontOfSize:10];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
