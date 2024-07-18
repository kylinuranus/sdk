//
//  SOSEditUserInfoViewController.h
//  Onstar
//
//  Created by lmd on 2017/9/1.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
    SOSEditUserInfoViewController *vc = [[NSClassFromString(@"SOSEditUserInfoViewController") alloc] init];
    vc.editType = SOSEditUserInfoTypeMailAdd;
    vc.originLabelString = @"liumengdi666@163.com";
    vc.fixOkBlock = ^(NSString *text) {
        NSLog(@"text= %@",text);
    };
    [self.navigationController pushViewController:vc animated:YES];
*/

@interface SOSEditUserInfoViewController : SOSBaseViewController

@property (nonatomic, assign) SOSEditUserInfoType editType;
@property (nonatomic, copy)   NSString *govid;//身份证
@property (nonatomic, copy)   NSString *originLabelString;
@property (nonatomic, copy)   void((^fixOkBlock)(NSString *text));

@end
