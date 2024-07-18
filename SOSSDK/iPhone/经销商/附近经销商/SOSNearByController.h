//
//  SOSNearByController.h
//  Onstar
//
//  Created by WQ on 2018/7/5.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSNearByController : UIViewController
@property (nonatomic,strong) UITableView *dTable;

- (void)getNearByList:(SOSPOI*)location;
- (void)pushMapVc:(NNDealers *)dealers;

@end
