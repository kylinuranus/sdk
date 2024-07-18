//
//  SOSPageScrollParaCenter.h
//  Onstar
//
//  Created by lizhipan on 2017/7/28.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
//设置tableview header高度及悬浮
@interface SOSPageScrollParaCenter : NSObject
@property(nonatomic,assign)CGFloat headerTotalHeight; //总高度
@property(nonatomic,assign)BOOL disableStick;         //不悬停，随tableview移动
@property(nonatomic,assign)CGFloat stickHeight;       //悬停高度
@property(nonatomic,assign)CGFloat headerSeprateHeight; //headerView距离下部界面分割高度
@property(nonatomic,assign)CGFloat navigationBarHeight; //
@end
