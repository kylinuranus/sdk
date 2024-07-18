//
//  SOSPersonInfoItem.h
//  Onstar
//
//  Created by lizhipan on 2017/8/3.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOSPersonInfoItem : NSObject
@property (nonatomic ,assign)NSInteger itemIndex;
///左边显示内容
@property (nonatomic ,copy)NSString * itemDescription;
///实际提交内容
@property (nonatomic ,copy)NSString * itemResult;
///右边显示内容
@property (nonatomic ,copy)NSString * itemPlaceholder;
///* 必须标示是否可见
@property (nonatomic ,assign)BOOL isNecessities;
///右箭头是否可见,以及该项是否可编辑
@property (nonatomic ,assign)BOOL accessoryVisiable;
///右半部分区域自定义
@property (nonatomic ,strong)UIView *rightFieldView;
///标志符
@property (nonatomic ,copy)NSString * enrollKey;
///键盘类型
@property (nonatomic ,assign) UIKeyboardType keyBoardType;
///最大输入长度
@property (nonatomic ,assign) int maxInputLength;

- (instancetype)initWithItemDesc:(NSString *)itemDesc itemResult:(NSString *)result itemIndex:(NSInteger )index_ isNecessary:(BOOL)isNecess rightArrowVisiable:(BOOL)showRightArrow;
- (NSString *)personInfoValue;
- (BOOL)isValidateValue;
@end
