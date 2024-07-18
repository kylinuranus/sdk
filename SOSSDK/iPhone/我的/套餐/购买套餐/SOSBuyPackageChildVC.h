//
//  SOSBuyPackageChildVC.h
//  Onstar
//
//  Created by Coir on 7/9/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSPackageHeader.h"

@interface SOSBuyPackageChildVC : UIViewController

@property (nonatomic, copy) PackageInfos *selectedPackage;

@property (nonatomic, copy) NSArray *packageArray;

/** 套餐类型 */
@property (nonatomic, assign) PackageType packageType;

@end
