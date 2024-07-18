//
//  SOSRegisterTextField.h
//  Onstar
//
//  Created by lizhipan on 2017/8/16.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITextField+Keyboard.h"
//有自定义inpputaccessoryview、验证码倒计时、secureTextEntry眼睛
@interface SOSRegisterTextField : UITextField
//输入过滤特殊表情字符
- (void)addTextInputPredicate ;
//设置rightview，验证码倒计时
- (void)setupVerifyCodeRightViewWithDelegate:(id)del Method:(SEL)sel;
//设置rightview，眼睛图标控制field是否secureTextEntry
- (void)setupPasswordField;
//设置rightview，下拉列表
- (void)setupDropdownComboboxDelegate:(id)del Method:(SEL)sel;
- (void)setupScanButtonWithDelegate:(id)del responseMethod:(SEL)sel;
- (void)clearRightView;
- (void)addNormalBorderStyle;
@end
//注册／用户信息地址中数字显示***
@interface SOSRegisterAddressTextField : SOSRegisterTextField
@property(nonatomic,copy)NSString * realText;//***代表的实际内容
@end
