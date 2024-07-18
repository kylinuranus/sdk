//
//  TLServiceSettingViewModel.h
//  Onstar
//
//  Created by TaoLiang on 2017/10/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SystemSettingCellData.h"
#import "SOSServiceSettingViewController.h"

typedef NS_ENUM(NSInteger,SOSBleSwitchStatus) {
    SOSBleSwitchStatusUnknow,
    SOSBleSwitchStatusOff,
    SOSBleSwitchStatusOn,
    SOSBleSwitchStatusUnBind    //未绑定
};


@interface TLServiceSettingViewModel : NSObject
@property (strong, nonatomic) NSMutableArray <SystemSettingCellData *>*sectionOneArray;
@property (strong, nonatomic) NSMutableArray <SystemSettingCellData *>*sectionTwoArray;
@property (strong, nonatomic) NSMutableArray <SystemSettingCellData *>*sectionThreeArray;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (nonatomic, assign) SOSBleSwitchStatus bleSwitchStatus;

- (instancetype)initWithVC:(SOSServiceSettingViewController *)vc;

- (NSArray <NSMutableArray *>*)cookData;

- (UIView *)getTableFooterView;

- (void)clearData;
@end
