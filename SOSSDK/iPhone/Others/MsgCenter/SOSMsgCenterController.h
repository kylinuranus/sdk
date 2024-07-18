//
//  SOSMsgCenterController.h
//  Onstar
//
//  Created by WQ on 2018/5/21.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSMsgCenterController : UIViewController

- (void)goActivity;
- (void)goStarAst;

- (void)goNotifyWithCategory:(NSString *)cat categoryTitle:(NSString *)title;
- (void)delMsg:(NSString*)category;

@end
