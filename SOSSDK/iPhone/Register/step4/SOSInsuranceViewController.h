//
//  SOSInsuranceViewController.h
//  Onstar
//
//  Created by lizhipan on 2017/9/12.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSUInteger, SOSInsuranceVCPageType)	{
	SOSInsuranceVCPageType_VehicleInfo = 1,
    SOSInsuranceVCPageType_OwnerLife = 2,
    SOSInsuranceVCPageType_BBWC = 3,
};

@interface SOSInsuranceViewController : SOSBaseViewController
@property (copy,   nonatomic) void(^selectInsurenceBlock)(NSString * insurence);
@property (weak,   nonatomic) IBOutlet UITableView *insuranceTable;
@property (assign, nonatomic) BOOL needUpdateInfo;
@property (copy,   nonatomic) NSString *sourceInsurance;

@property (assign, nonatomic) SOSInsuranceVCPageType pageType;
@end
