//
//  SOSInfoFlowArchiver.m
//  Onstar
//
//  Created by TaoLiang on 2018/12/19.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSInfoFlowArchiver.h"

#define INFO_FLOW_EXPIRATION_KEY @"INFO_FLOW_EXPIRATION_KEY"

@implementation SOSInfoFlowArchiver



+ (BOOL)archiveInfoFlows:(NSArray *)infoFlows {
    BOOL success = [NSKeyedArchiver archiveRootObject:infoFlows toFile:[self getInfoFlowFilePath]];
    if (success) {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
        [[NSUserDefaults standardUserDefaults] setDouble:timeInterval forKey:[self getExpirationKey]];
    }
    return success;
}

+ (NSArray *)unarchiveInfoFlows {
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:[self getInfoFlowFilePath]];
    return array;
}

+ (NSString *)getInfoFlowFilePath {
    NSString *fileName = [[self getFileName] stringByAppendingString:@".plist"];
    NSString *filePath = [[self getInfoFlowDirectoryPath] stringByAppendingPathComponent:fileName];
    return filePath;
}

+ (BOOL)isExpired {
    NSTimeInterval timeInterval = [[NSUserDefaults standardUserDefaults] doubleForKey:[self getExpirationKey]];
    NSDate *savedDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:savedDate];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:[NSDate date]];
    BOOL isSameDay = comp1.day == comp2.day && comp1.month == comp2.month && comp1.year == comp2.year;
    return !isSameDay;
}

+ (NSString *)getInfoFlowDirectoryPath {
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *infoFlowPath = [documentsPath stringByAppendingPathComponent:@"InfoFlow"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:infoFlowPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:infoFlowPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return infoFlowPath;
}

+ (NSString *)getFileName {
    NSMutableString *fileName = @"".mutableCopy;
    [fileName appendString:[CustomerInfo sharedInstance].userBasicInfo.idpUserId ? : @"unKnowUser"];
    [fileName appendString:@"_"];
    [fileName appendString:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin ? : @"unKnowVin"];
    return fileName.md5String.copy;
}

+ (NSString *)getExpirationKey {
    return [INFO_FLOW_EXPIRATION_KEY stringByAppendingString:[self getFileName]];
}

@end
