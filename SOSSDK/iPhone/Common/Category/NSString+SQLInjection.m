//
//  NSString+SQLInjection.m
//  Onstar
//
//  Created by TaoLiang on 2017/11/13.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "NSString+SQLInjection.h"

@implementation NSString (SQLInjection)


- (NSString *)transactSQLInjection {
    NSString *filteredStr = [self stringByReplacingRegex:@".*([';]+|(--)+).*" options:NSRegularExpressionCaseInsensitive withString:@" "];
    return filteredStr;
//    NSString *filteredStr;
//    filteredStr = [self stringByReplacingOccurrencesOfString:@"'" withString:@" "];
//    filteredStr = [filteredStr stringByReplacingOccurrencesOfString:@"--" withString:@" "];
//    filteredStr = [filteredStr stringByReplacingOccurrencesOfString:@";" withString:@" "];
//    return filteredStr;
}
- (BOOL)sql_inj:(NSString *)str{
    
    NSString *inj_str = @"|and|exec|insert|select|delete|update|count|*|%|chr|mid|master|truncate|char|declare|;|or|-|+|,";
    NSArray <NSString *> * sep = [inj_str componentsSeparatedByString:@"|"];
    
    for (int i=0 ; i < sep.count ; i++ ){
        
        if ([str rangeOfString:str].location == 0){
            
            return true;
        }
    }
    return false;
}
@end
