//
//  SOSNotifyView.h
//  Onstar
//
//  Created by WQ on 2018/5/25.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSNotifyController.h"

@interface SOSNotifyView : UIView <UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,weak)SOSNotifyController *parentVC;
@property(nonatomic,strong)MessageCenterListModel *model;
@property(nonatomic,strong)NotifyOrActModel *endModel;
@property(nonatomic,strong)NSMutableArray<NSArray*> *datas;
@property(nonatomic,assign)NSInteger unreadNum;
@property(nonatomic,assign)NSInteger totalNum;
@property(nonatomic,assign)BOOL useCustomCell;

+ (SOSNotifyView*)instanceView;
- (void)begin;
- (void)update;
- (void)endRefresh;
- (void)editHead;

@end
