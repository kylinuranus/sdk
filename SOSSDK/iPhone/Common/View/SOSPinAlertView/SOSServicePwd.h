//
//  SOSServicePwd.h
//  Onstar
//
//  Created by Genie Sun on 2017/7/28.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface SOSServicePwd : UIView <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet SOSCustomTF *tf;
@property(nonatomic, assign) BOOL isFlashSelected;
@property(nonatomic, assign) BOOL isHornSelected;
@property(nonatomic, strong) UIButton *buttonOK;
@property(nonatomic, strong) UIButton *eyeBtn;
@property(nonatomic, copy) NSString * functionID;

@property (nonatomic, assign)BOOL isHornFlash;
@property (weak, nonatomic) IBOutlet UIView *viewHorn;
@property (weak, nonatomic) IBOutlet UIView *viewFlash;
@property (weak, nonatomic) IBOutlet UIButton *buttonHorn;
@property (weak, nonatomic) IBOutlet UIButton *buttonFlash;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeightCons;

@property (copy, nonatomic) void (^feedback)(void);

@end
