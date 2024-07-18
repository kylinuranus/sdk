//
//  VolationList.m
//  Onstar
//
//  Created by Vicky on 15/5/8.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import "ViolationList.h"


@implementation Violation

@end

@implementation ViolationList
- (id)initWithDictionary:(NSDictionary *)dictionary     {
	self = [super init];
	if (self)
	{
		
		_violationList = [NSMutableArray array];
		NSArray *_violations = [NSArray new];
		_violations = dictionary[@"list"];
		if ([_violations isKindOfClass:[NSArray class]]) {
			
			for (int i=0; i< [_violations count]; i++)
			{
				Violation *vo = [[Violation alloc]init];
				vo.time = _violations[i][@"time"];
				vo.fine = _violations[i][@"price"];
				vo.violation_type = _violations[i][@"content"];
				vo.address = _violations[i][@"address"];
				vo.point = _violations[i][@"score"];
				vo.code = _violations[i][@"legalnum"];
                vo.handled =_violations[i][@"agency"];
				[_violationList addObject:vo];
			}
		} else if ([_violations isKindOfClass:[NSDictionary class]]) {
			Violation *vo = [[Violation alloc]init];
						NSDictionary *violationDic = [NSDictionary new];
						violationDic = (NSDictionary *)_violations;
			vo.time = violationDic[@"time"];
			vo.fine = violationDic[@"price"];
			vo.violation_type =violationDic[@"content"];
			vo.address = violationDic[@"address"];
			vo.point = violationDic[@"score"];
			vo.code = violationDic[@"legalnum"];
            vo.handled =violationDic[@"agency"];

			[_violationList addObject:vo];
		}
		_totalCount = (int)[_violationList count] ;
	}
	return self;
}
@end
