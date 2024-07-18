//
//  UIColor+common.m
//  Onstar
//
//  Created by WQ on 2018/5/31.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "UIColor+common.h"

@implementation UIColor (common)

+ (UIColor*)Gray246
{
    return [UIColor colorWithRed:246/255.0 green:243/255.0 blue:247/255.0 alpha:1];
}

+ (UIColor*)Gray238
{
    return [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
}

+ (UIColor*)Gray185
{
    return [UIColor colorWithRed:185/255.0 green:185/255.0 blue:185/255.0 alpha:1];
}

+ (UIColor*)Gray129
{
    return [UIColor colorWithRed:129/255.0 green:130/255.0 blue:135/255.0 alpha:1];
}

+ (UIColor*)LineGray
{
    return [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1];
}

+ (UIColor*)Gray153
{
    return [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
}

+ (UIColor*)Gray102
{
    return [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
}

+ (UIColor*)Gray78
{
    return [UIColor colorWithRed:78/255.0 green:80/255.0 blue:89/255.0 alpha:1];
}

+ (UIColor*)Gray52
{
    return [UIColor colorWithRed:52/255.0 green:52/255.0 blue:52/255.0 alpha:1];
}

+ (UIColor*)skyBlue
{
    return [UIColor colorWithRed:30/255.0 green:144/255.0 blue:255/255.0 alpha:1];
}
+ (UIColor*)cadiStytle{
    return  [UIColor colorWithHexString:@"#B5A36A"];
}
+ (instancetype)sos_ColorWithHexString:(NSString *)hexStr {
    CGFloat r, g, b, a;
    if (hexStrToRGBA(hexStr, &r, &g, &b, &a)) {
        return [UIColor colorWithRed:r green:g blue:b alpha:a];
    }
    return nil;
}


static inline NSUInteger hexStrToInt(NSString *str) {
    uint32_t result = 0;
    sscanf([str UTF8String], "%X", &result);
    return result;
}

static BOOL hexStrToRGBA(NSString *str,
                         CGFloat *r, CGFloat *g, CGFloat *b, CGFloat *a) {
    str = [[str stringByTrim] uppercaseString];
    if ([str hasPrefix:@"#"]) {
        str = [str substringFromIndex:1];
    } else if ([str hasPrefix:@"0X"]) {
        str = [str substringFromIndex:2];
    }
    
    NSUInteger length = [str length];
    //         RGB            RGBA          RRGGBB        RRGGBBAA
    if (length != 3 && length != 4 && length != 6 && length != 8) {
        return NO;
    }
    
    //RGB,RGBA,RRGGBB,RRGGBBAA
    if (length < 5) {
        *r = hexStrToInt([str substringWithRange:NSMakeRange(0, 1)]) / 255.0f;
        *g = hexStrToInt([str substringWithRange:NSMakeRange(1, 1)]) / 255.0f;
        *b = hexStrToInt([str substringWithRange:NSMakeRange(2, 1)]) / 255.0f;
        if (length == 4)  *a = hexStrToInt([str substringWithRange:NSMakeRange(3, 1)]) / 255.0f;
        else *a = 1;
    } else {
        *r = hexStrToInt([str substringWithRange:NSMakeRange(0, 2)]) / 255.0f;
        *g = hexStrToInt([str substringWithRange:NSMakeRange(2, 2)]) / 255.0f;
        *b = hexStrToInt([str substringWithRange:NSMakeRange(4, 2)]) / 255.0f;
        if (length == 8) *a = hexStrToInt([str substringWithRange:NSMakeRange(6, 2)]) / 255.0f;
        else *a = 1;
    }
    return YES;
}

+ (UIColor*)sos_skinColorWithKey:(NSString *)skinKey{
//#ifdef SOSSDK_SDK
//
//#else
    NSString *jsonpath;
    if (SOS_APP_DELEGATE.useSkin) {
          NSBundle * bPath = SOSSkinBundlePath();
          jsonpath = [bPath pathForResource:@"Skin" ofType:@"json"];
    }else{
          jsonpath = [[NSBundle SOSBundle] pathForResource:@"Skin" ofType:@"json"];
    }
    NSString * json = [NSString stringWithContentsOfFile:jsonpath encoding:NSUTF8StringEncoding error:nil];
    NSDictionary * dic = [Util dictionaryWithJsonString:json];
    NSArray * keyArr = [skinKey componentsSeparatedByString:@"."];
    if (keyArr.count==3) {
        return [UIColor colorWithHexString:[[[dic valueForKey:[keyArr objectAtIndex:0]] valueForKey:[keyArr objectAtIndex:1]] valueForKey:[keyArr objectAtIndex:2]]];
    }
    return [UIColor whiteColor];
//#endif
    
}
@end
