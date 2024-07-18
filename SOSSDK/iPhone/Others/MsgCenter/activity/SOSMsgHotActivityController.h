//
//  SOSMsgHotActivityController.h
//  Onstar
//
//  Created by WQ on 2018/5/22.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSMsgHotActivityController : UIViewController

@property(nonatomic,assign)NSInteger unreadNum;
@property(nonatomic,assign)NSInteger totalNum;
@property(nonatomic,assign)BOOL isPush;    //是否点击推送唤起app后进入本页
@property(nonatomic,copy)NSString *pushUrl;         //推送显示的url

- (void)go:(BOOL)isDragDown pageNO:(NSInteger)num;
- (void)cleanData;

@end
