//
//  SetHomeHeaderCell.m
//  Onstar
//
//  Created by Coir on 16/2/17.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "SetHomeHeaderCell.h"
#import "SOSCollectViewController.h"
#import "SOSTripPOIVC.h"

@implementation SetHomeHeaderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.myPositionButton setTitleForNormalState:@"我的位置"];
    [self.buttonCenter setTitleForNormalState:@"地图选点"];
    [self.buttonFavorite setTitleForNormalState:@"收藏夹"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)showCollections:(UIButton *)sender {
    ////[[SOSReportService shareInstance] recordActionWithFunctionID:Homesetting_clickfavorite];
    SOSCollectViewController *vc = [SOSCollectViewController new];
    [self.nav pushViewController:vc animated:YES];
}

@end
