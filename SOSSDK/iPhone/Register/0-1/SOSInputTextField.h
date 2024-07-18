//
//  MyTextField.h
//  TextFieldDemo
//
//  Created by lmd on 2017/8/24.
//  Copyright © 2017年 Fentech. All rights reserved.
//

#import "SOSRegisterTextField.h"

typedef NS_ENUM(NSInteger, SOSInputViewStatus) {
    SOSInputViewStatusNormal,       //
    SOSInputViewStatusEditing,      //
    SOSInputViewStatusChecking,     //显示菊花
    SOSInputViewStatusSuccess,      //显示成功图片
    SOSInputViewStatusError,        //显示错误图片及错误信息(password只显示text)
};

@interface SOSInputTextField : SOSRegisterTextField

@property (nonatomic, copy) NSString *normalText;
@property (nonatomic, copy) NSString *errorText;
@property (nonatomic, assign) SOSInputViewStatus inputStatus;

- (void)showError:(NSString *)text;


@end
