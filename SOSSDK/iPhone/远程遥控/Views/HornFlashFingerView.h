//
//  HornFlashFingerView.h
//  Onstar
//
//  Created by Vicky on 16/2/19.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HornFlashFingerView : UIView
@property (nonatomic, assign)BOOL isHornFlash;

@property (nonatomic,copy) void (^completeHandle)(NSString *inputPwd,BOOL flashSelected,BOOL hornSelected);

@property (nonatomic,copy) void (^OpenPINView)(BOOL open);

- (void)show;
@end
