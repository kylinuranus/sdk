//
//  NavigateSearchVC.h
//  Onstar
//
//  Created by Genie Sun on 2017/8/9.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseSearchTableVC.h"

@interface NavigateSearchVC : BaseSearchTableVC

/// 设置搜索页面为选点模式,设置选点操作类型    (若不需要,传0或不设置)
//@property (nonatomic, assign) SelectPointOperation operationType;

@property(nonatomic, assign) EditStatus editStatus;

- (void)changeSearchKeywords:(NSString *)keywords;
+ (BOOL)canComeBackToSearchVCFromNav:(UINavigationController *)navVC;

@end
