//
//  SOSMsgCenterView.h
//  Onstar
//
//  Created by WQ on 2018/5/21.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSMsgCenterController.h"

@interface SOSMsgCenterView : UIView

@property(nonatomic,weak)SOSMsgCenterController *parent;
@property(nonatomic,strong)MessageCenterModel *model;
@property(nonatomic,strong)NSArray *banners;

+ (SOSMsgCenterView*)instanceView;
- (void)update;
- (void)updateBanner;
- (void)hiddenBanner;
- (void)viewDidLayout;
@end
