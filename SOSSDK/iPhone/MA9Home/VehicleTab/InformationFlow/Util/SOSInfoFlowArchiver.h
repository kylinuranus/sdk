//
//  SOSInfoFlowArchiver.h
//  Onstar
//
//  Created by TaoLiang on 2018/12/19.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

/**实现归档解档的宏*/
#define SOS_IMPLEMENTATION_CODING \
- (void)encodeWithCoder:(NSCoder *)aCoder { \
NSArray * properNames = [self properNames]; \
for (NSString * properName in properNames) { \
id value = [self valueForKey:properName]; \
if (value && properName) { \
[aCoder encodeObject:value forKey:properName]; \
} \
} \
} \
\
- (instancetype)initWithCoder:(NSCoder *)aDecoder { \
if (self = [super init]) { \
NSArray * properNames = [self properNames]; \
for (NSString * properName in properNames) { \
id value = [aDecoder decodeObjectForKey:properName]; \
if (value && properName) { \
[self setValue:value forKey:properName]; \
} \
} \
} \
return self; \
} \
\
- (NSArray<NSString*>*)properNames { \
unsigned int count; \
Ivar * ivarList = class_copyIvarList([self class], &count); \
NSMutableArray * propers = [NSMutableArray array]; \
for (int i = 0; i<count; i++) { \
Ivar ivar = ivarList[i]; \
NSString *name = [NSString stringWithUTF8String:ivar_getName(ivar)];\
NSString * key = [name substringFromIndex:1]; \
[propers addObject:key]; \
} \
free(ivarList); \
return propers; \
}

NS_ASSUME_NONNULL_BEGIN

@interface SOSInfoFlowArchiver : NSObject
+ (BOOL)archiveInfoFlows:(NSArray *)infoFlows;
+ (NSArray *)unarchiveInfoFlows;
+ (BOOL)isExpired;
@end

NS_ASSUME_NONNULL_END
