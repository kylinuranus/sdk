//
//  SOSOilGanSelectChildVC.h
//  Onstar
//
//  Created by Coir on 2019/9/1.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSOilGanSelectChildVC : UIViewController

/// 缺省变量,仅用于标识油站 ID 以及油站名称,以便于请求油枪信息
@property (nonatomic, strong) SOSOilStation *stationOilInfo;

@property (nonatomic, strong) NSString *selectedGunNo;

- (void)showLoadingView;

- (void)stopLoadingView;

@end

NS_ASSUME_NONNULL_END
