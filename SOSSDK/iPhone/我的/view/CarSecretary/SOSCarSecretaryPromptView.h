//
//  SOSCarSecretaryPromptView.h
//  Onstar
//
//  Created by TaoLiang on 2018/1/29.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSCarSecretaryPromptView : UIView

@property (copy, nonatomic) void (^closeBtnClicked)(void);
@property (copy, nonatomic) void (^viewTapped)(void);
+ (instancetype)viewWithPrompt:(NSString *)prompt;
- (void)show;
@end
