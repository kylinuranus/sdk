//
//  SOSRegularCellItem.h
//  Onstar
//
//  Created by lizhipan on 2017/8/7.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOSRegularCellItem : NSObject
@property(nonatomic,weak)NSString * titleStr;   //标题
@property(nonatomic,weak)NSString * iconStr;    //图标
@property(nonatomic,weak)NSString * contentImageStr;//主内容为图片的图片名称
@property(nonatomic,assign)NSInteger  itemIndex;    //序列
@property(nonatomic,assign)BOOL  hiddenRightArrow;  //是否隐藏右箭头
@end
