//
//  SOSBangcleKBTextField.h
//  Onstar
//
//  Created by Onstar on 2019/6/5.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//
//#if __has_include(<BangcleSafeKeyBoard/BangcleSafeKeyBoard.h>)
//#import <BangcleSafeKeyBoard/BangcleSafeKeyBoard.h>
//#endif

NS_ASSUME_NONNULL_BEGIN

@interface SOSBangcleKBTextField : UITextField
//设置rightview，眼睛图标控制field是否secureTextEntry
- (void)setupPasswordField;
- (void)addNormalBorderStyle;
@end

NS_ASSUME_NONNULL_END
