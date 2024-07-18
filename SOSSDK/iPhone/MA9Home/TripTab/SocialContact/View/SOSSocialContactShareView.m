//
//  SOSSocialContactShareView.m
//  Onstar
//
//  Created by onstar on 2019/4/19.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSSocialContactShareView.h"

@interface SOSSocialContactShareView()
@property (weak, nonatomic) IBOutlet UIView *firstShareView;
@property (weak, nonatomic) IBOutlet UIView *secondShareView;
@property (weak, nonatomic) IBOutlet UIView *threeShareView;
@property (weak, nonatomic) IBOutlet UIView *fourShareView;

@property (nonatomic, strong) NSArray *shareViewList;

@end

@implementation SOSSocialContactShareView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.firstShareView.userInteractionEnabled = YES;
    @weakify(self);
    [self.firstShareView setTapActionWithBlock:^{
        @strongify(self);
        !self.shareTapBlock?:self.shareTapBlock(0);
    }];
    self.secondShareView.userInteractionEnabled = YES;
    [self.secondShareView setTapActionWithBlock:^{
        @strongify(self);
        !self.shareTapBlock?:self.shareTapBlock(1);
    }];
    self.shareViewList = @[
                           self.firstShareView,
                           self.secondShareView,
                           self.threeShareView,
                           self.fourShareView
                           ];
}

- (void)setShareChannels:(NSArray *)shareChannels {
    _shareChannels = shareChannels;
    for (int i=0; i<shareChannels.count; i++) {
        NSDictionary *dic = shareChannels[i];
        NSString *icon = dic[@"icon"];
        NSString *title = dic[@"title"];
        UIView *contentView =self.shareViewList[i];
        contentView.hidden = NO;
        UIImageView *imgView = [contentView viewWithTag:10];
        UILabel *titleLabel = [contentView viewWithTag:11];
        imgView.image = [UIImage imageNamed:icon];
        titleLabel.text = title;
        
        contentView.userInteractionEnabled = YES;
        @weakify(self);
        [contentView setTapActionWithBlock:^{
            @strongify(self);
            !self.shareTapBlock?:self.shareTapBlock(i);
            if (self.shareTapCallback) {
                self.shareTapCallback(@[dic[@"icon"],dic[@"functionID"]]);
            }
        }];
        
    }
    
}

@end
