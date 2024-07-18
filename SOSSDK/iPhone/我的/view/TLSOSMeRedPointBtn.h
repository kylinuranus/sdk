//
//  TLSOSMeRedPointBtn.h
//  Onstar
//
//  Created by TaoLiang on 2017/10/23.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TLSOSMeRedPointBtn : UIButton
@property (assign, nonatomic) NSUInteger unreadNum;
@property (strong, nonatomic) UIView *redPoint;
@property (assign, nonatomic) BOOL showNum;   //addByWQ
@property (assign, nonatomic) CGFloat radius;

@end
