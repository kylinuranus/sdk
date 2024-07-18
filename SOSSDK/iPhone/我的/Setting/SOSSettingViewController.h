//
//  SOSSettingViewController.h
//  Onstar
//
//  Created by lizhipan on 2017/8/2.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSBaseSegmentViewController.h"

@interface SOSSettingViewController : SOSBaseSegmentViewController 

//h5调用原生 返回需要刷新的时候调用
@property (nonatomic, copy) void (^refreshH5Block)(void);
@property (nonatomic,copy)NSString *fromVC;    //来源，有些界面需要自动回退
@property (nonatomic, copy) void (^popBlock)(void);

@end
