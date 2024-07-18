//
//  AutoNaviObject.h
//  AutoNaviTelematrics
//
//  Created by Joshua on 15-3-31.
//  Copyright (c) 2015年 onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AutoNaviObject : NSObject

@property (nonatomic, strong) NSMutableDictionary *paramDict;

- (void)saveParam:(NSString *)value forKey:(NSString *)key;
- (NSString *)valueJointStringForArray:(NSArray *)keyArray;
- (NSString *)objToString;
@end
