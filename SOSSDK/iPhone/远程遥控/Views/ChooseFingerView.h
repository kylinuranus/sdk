//
//  ChooseFingerView.h
//  Onstar
//
//  Created by Vicky on 16/2/19.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseFingerView : UIView
@property (nonatomic,copy) void (^openFingerView)(BOOL flag);
@property (nonatomic,copy) void (^openPINCodeView)(BOOL flag);
- (void)show;
@end
