//
//  SOSVerifyPersionInfoView.h
//  Onstar
//
//  Created by Coir on 12/03/2018.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 页面类型
typedef NS_ENUM	(int)	{
    /// 个人信息
	SOSVerifyTypePersonInfo = 1,
    /// 星用户信息
	SOSVerifyTypeStarInfo = 2
} SOSVerifyType;

@interface SOSVerifyPersonInfoView : UIView

@property (nonatomic, assign) SOSVerifyType pageType;

@property (nonatomic, weak) UINavigationController *nav;
@property (nonatomic, copy) NSString *verURI;
@property (nonatomic, copy) NSString *verifyTip;

@end
