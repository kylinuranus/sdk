//
//  FMHorizontalMenuCollectionLayout.h
//  YFMHorizontalMenu
//
//  Created by FM on 2018/11/26.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSHorizontalMenuCollectionLayout : UICollectionViewLayout

@property (nonatomic,assign) NSInteger rowCount;

@property (nonatomic,assign) NSInteger columCount;


/**
 预计算 contentSize 大小
 */
@property (nonatomic,assign) CGSize contentSize;
/**
 预计算所有的 cell 布局属性
 */
@property (strong,nonatomic) NSMutableArray<UICollectionViewLayoutAttributes *> *layoutAttributes;


/**
 获取当前页数

 @return 页数
 */
-(NSInteger)currentPageCount;
@end
