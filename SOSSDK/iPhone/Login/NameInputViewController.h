//
//  NameInputViewController.h
//  Onstar
//
//  Created by lizhipan on 17/3/14.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
//info3.0用户补充姓名界面
typedef void (^submitCompletedBlock)(NSString *firstName,NSString * lastName);

@interface NameInputViewController : SOSBaseViewController
@property(nonatomic,copy)submitCompletedBlock completeBlock;
@end
