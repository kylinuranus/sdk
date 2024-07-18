//
//  SOSSkinManager.m
//  Onstar
//
//  Created by Onstar on 2019/12/19.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSSkinManager.h"
#import "SOSDateFormatter.h"

@implementation SOSSkinManager
+ (NSString *)skinDocumentsPath {
    NSString *sPath = [[[UIApplication sharedApplication] documentsPath] stringByAppendingPathComponent:@"Skin"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:sPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:sPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return sPath;
}
+(BOOL)hasNewSkin{
    
//#if DEBUG || TEST
//    if (UserDefaults_Get_Bool(@"skinmock")) {
//          //showshare
//        UserDefaults_Set_Bool(NO, @"skinmock");
//        return YES;
//    }else{
//        UserDefaults_Set_Bool(YES, @"skinmock");
//        return NO;
//    }
//#endif

     NSString *jsonpath;
     NSBundle * bPath = SOSSkinBundlePath();
     jsonpath = [bPath pathForResource:@"Skin" ofType:@"json"];
     NSString * json = [NSString stringWithContentsOfFile:jsonpath encoding:NSUTF8StringEncoding error:nil];
    NSDictionary * dic = [Util dictionaryWithJsonString:json];
    NSString * startTime = [dic objectForKey:@"activityStartTime"];
    NSString * endTime = [dic objectForKey:@"activityEndTime"];
    NSDate *today = [NSDate date];
    NSDate *start = [[SOSDateFormatter sharedInstance] style4_dateFromString:startTime];
    NSDate *expire =  [[SOSDateFormatter sharedInstance] style4_dateFromString:endTime];
       if ([today compare:start] == NSOrderedDescending && [today compare:expire] == NSOrderedAscending) {
           return YES;
       }
       return NO;
}

@end
