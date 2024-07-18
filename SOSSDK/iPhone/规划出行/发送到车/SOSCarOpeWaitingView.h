//
//  SOSCarOpeWaitingView.h
//  Onstar
//
//  Created by TaoLiang on 2017/10/31.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

///发送状态
typedef NS_ENUM(NSUInteger, Status) {
    ///发送中
    StatusLoading,
    ///发送失败
    StatusFailure,
    ///发送成功
    StatusSuccess
};

@interface SOSCarOpeWaitingView : UIView
@property (copy, nonatomic) NSString *prompt;
@property (assign, nonatomic) Status status;
@property(copy, nonatomic) void (^doneBtnClicked)(void);

@end
