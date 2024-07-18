//
//  VolationList.h
//  Onstar
//
//  Created by Vicky on 15/5/8.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Violation : NSObject

@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *fine;
@property (nonatomic, strong) NSString *point;
@property (nonatomic, strong) NSString *violation_type;
@property (nonatomic, strong) NSString *handled;//罚款机构
@property (nonatomic, strong) NSString *code;

@end

@interface ViolationList : NSObject

@property(nonatomic,copy) NSMutableArray *violationList;
@property(nonatomic,assign) int totalCount;

- (id)initWithDictionary:(NSDictionary *)dictionary;
@end
