//
//  SOSSearchViewController.h
//  Onstar
//
//  Created by Genie Sun on 2017/8/9.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSBaseSegmentViewController.h"

@interface SOSSearchViewController : SOSBaseSegmentViewController
@property(nonatomic, strong) UITextField *tf;

@property(nonatomic, assign) BOOL fromGeoFecing;
@property(nonatomic, assign) EditStatus editStatus;

@property (nonatomic, strong) NNGeoFence *geoFence;

/// 设置 家和公司地址 类型    (若不需要,传0或不设置)
@property (nonatomic, assign) SelectPointOperation operationType;

@property(nonatomic, strong) NSArray *items;

- (instancetype)initWithItems:(NSArray *)itemsArray;

@end
