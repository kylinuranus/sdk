//
//  SOSMeTabHeaderView.h
//  Onstar
//
//  Created by Onstar on 2018/12/20.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSModuleProtocols.h"
NS_ASSUME_NONNULL_BEGIN
//我的 表头
@interface SOSMeTabHeaderView : UIView
@property(nonatomic, weak) id<SOSHomeMeTabProtocol> delegate;
//未登录状态
-(void)configUnloginState;
//登录中状态(suite回来前)
-(void)configLoadingState;
//登录后状态
-(void)configLoginSuccessState;
//刷新包状态
-(void)refreshPackageState;
@end

NS_ASSUME_NONNULL_END
