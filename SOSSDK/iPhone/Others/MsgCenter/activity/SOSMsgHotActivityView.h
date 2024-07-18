//
//  SOSMsgHotActivityView.h
//  Onstar
//
//  Created by WQ on 2018/5/22.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSMsgHotActivityController.h"

@interface SOSMsgHotActivityView : UIView

@property(nonatomic,strong)MessageCenterListModel *model;
@property(nonatomic,strong)NSMutableArray<NSMutableArray*>*datas;
@property(nonatomic,assign)NSInteger unreadNum;
@property(nonatomic,assign)NSInteger totalNum;
@property(nonatomic,weak)SOSMsgHotActivityController *parent;

+ (SOSMsgHotActivityView*)instanceView;
- (void)begin;
- (void)update;
- (void)endRefresh;
- (void)editHead;

@end
