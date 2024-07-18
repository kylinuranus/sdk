//
//  SOSOnstarPackageChildVC.h
//  Onstar
//
//  Created by Coir on 5/9/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSPackageHeader.h"

///安吉星套餐页面的 Child VC
@interface SOSOnstarPackageChildVC : UIViewController

@property (nonatomic, copy) NSArray *packageInfoArray;

///页面类型
@property (nonatomic, assign) ChildVCType pageType;

@end
