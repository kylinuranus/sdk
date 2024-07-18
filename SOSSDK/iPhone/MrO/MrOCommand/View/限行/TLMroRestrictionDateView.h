//
//  TLMroRestrictionDateView.h
//  Onstar
//
//  Created by TaoLiang on 2017/11/22.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLMroRestriction.h"

@interface TLMroRestrictionDateView : UIView
@property (copy, nonatomic) void(^selectedBlock)(NSUInteger selectIndex, NSDate *date);
@property (strong, nonatomic) NSArray <NSDate *>*showDateArray;
@property (assign, nonatomic) NSUInteger selectIndex;

@end
