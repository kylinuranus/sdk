//
//  NSString+SOSCategory.m
//  Onstar
//
//  Created by TaoLiang on 2017/12/15.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "NSString+SOSCategory.h"

@implementation NSString (SOSCategory)

+ (NSString *)maskNickName:(NSString *)nickName {
    if (!nickName.isNotBlank) {
        return @"";
    }
    NSUInteger length = [NSString getStringLength:nickName];
    if (length <= 12) {
        return nickName;
    }

    NSInteger sum = 0;
    NSInteger from = 0;
    NSInteger to = 0;
    NSString *maskedName = nickName;
    
    for(int i = 0; i<[nickName length]; i++){
        
        unichar strChar = [nickName characterAtIndex:i];
        
        if(strChar < 256){
            sum += 1;
        }
        else {
            sum += 2;
        }
        if (sum >= 6) {
            if (from == 0) {
                from = i + 1;
            }
            
        }
        if (sum >= length - 4) {
            
            if (to == 0) {
                to = i + 1;
            }
            break;
        }
        
    }
    
    if (to >= from) {
        NSString *fromString = [nickName substringToIndex:from];
        NSString *toString = [nickName substringFromIndex:to];
        maskedName = [NSString stringWithFormat:@"%@...%@",fromString, toString];
    }
    
    return maskedName;

}

+ (NSUInteger)getStringLength:(NSString *)str {
    NSUInteger characterLength = 0;
    char *p = (char *)[str cStringUsingEncoding:NSUnicodeStringEncoding];
    for (NSInteger i = 0, l = [str lengthOfBytesUsingEncoding:NSUnicodeStringEncoding]; i < l; i++) {
        if (*p) {
            characterLength++;
        }
        p++;
    }
    return characterLength;
}

- (NSURL *)makeNSUrlFromString
{
    return [NSURL URLWithString:self];
}
- (NSString *)maskedUserName
{
   
    if (self.length >3) {
        NSString *preStr = [self substringWithRange:NSMakeRange(0, 3)];
        NSString *rearStr = [self substringFromIndex:[self length]-3];
        return  [NSString stringWithFormat:@"%@****%@",preStr,rearStr];
    }else{
        return self;
    }

}
/**
 如果字符串是空则返回未登录
 @return 返回处理后字符串
 */
- (NSString *)ifStringNilReturnUnloginString{
    if (self.isNotBlank) {
        return self;
    }
    return @"UNLOGIN";
}

- (BOOL)isLegalPinCode {
    NSString *pinCodeEx = @"[A-Za-z0-9.-]{1,}";
    NSPredicate *pinCodeTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pinCodeEx];
    return [pinCodeTest evaluateWithObject:self];
}
- (BOOL)isValidateTel;
{
        return ![self isEqualToString: @"暂无电话号码"];
    
}


- (BOOL)isEmpty{
    if(!self) {
        return YES;
    }else {
        
        //A character set containing only the whitespace characters space (U+0020) and tab (U+0009) and the newline and next line characters (U+000A–U+000D,U+0085).
      
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
       
        //Returns a new string made by removing from both ends of the receiver characters contained in a given character set.
        
        NSString *trimedString = [self stringByTrimmingCharactersInSet:set];
    
        if([trimedString length] == 0) {
          return YES;

        }else {
            return NO;

        }

    }
}
- (NSString *)regularChar{
    if (self.length==0 || !self) {
           return nil;
       }
       NSError *error = nil;
       NSString *pattern = @"[^a-zA-Z0-9\u4e00-\u9fa5]";//正则取反
       NSRegularExpression *regularExpress = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];//这个正则可以去掉所有特殊字符和标点
       NSString *string = [regularExpress stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length]) withTemplate:@""];
       
       return string;
}
@end
