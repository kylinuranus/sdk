//
//  AssociateTips.h
//  Onstar
//
//  Created by Coir on 16/2/15.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOSMapHeader.h"

@protocol AssociateTipsDelegate <NSObject>

@optional

///返回包含AMapTip对象的数组
- (void)associateSearchDoneWithKeyWords:(NSString *)keyWords Results:(NSArray *)associateArray;

@end

@interface AssociateTips : NSObject

@property (nonatomic, weak) id <AssociateTipsDelegate> delegate;

///以keyWords进行联想搜索，cityName可以传nil
- (void)searchWithKeyWords:(NSString *)keyWords AndCityName:(NSString *)cityName;

@end
