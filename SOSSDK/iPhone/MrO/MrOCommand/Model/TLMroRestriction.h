//
//  TLMroResctrion.h
//  Onstar
//
//  Created by TaoLiang on 2017/11/21.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TLMroRestrictionData : NSObject

/**
 限行区域
 */
@property (copy, nonatomic) NSString *region;

/**
 限行号码
 */
@property (copy, nonatomic) NSString *num;

/**
 限行时段
 */
@property (copy, nonatomic) NSString *time;

/**
 特别提示
 */
@property (copy, nonatomic) NSString *remarks;
@end
//***************************************************

@interface TLMroRestrictionContent : NSObject
@property (copy, nonatomic) NSString *penalty;
@property (strong, nonatomic) NSArray <TLMroRestrictionData *>*data;

@end

//***************************************************

@interface TLMroRestriction : NSObject


////******接口返回字段*****///
@property (strong, nonatomic) TLMroRestrictionContent *content;
/**
 0000表示成功
 */
@property (copy, nonatomic) NSString *code;
@property (copy, nonatomic) NSString *message;
@property (copy, nonatomic) NSString *date;

@end


//***************************************************
@interface TLMroRestrictions : NSObject
//记录用户搜索的内容
@property (copy, nonatomic) NSString *searchCity;
@property (copy, nonatomic) NSString *searchCityCode;
@property (copy, nonatomic) NSString *searchDate;
@property (assign, nonatomic) BOOL isSearching;
///7天中用户选中的位置,初始化状态为NSUInteger
@property (assign, nonatomic) NSUInteger selectIndex;


@property (strong, nonatomic) NSArray <TLMroRestriction *>*sevenDayDatas;

- (void)copyFromAnthoerRestrictions:(TLMroRestrictions *)restriction;
@end

