//
//  UIColor+common.h
//  Onstar
//
//  Created by WQ on 2018/5/31.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#define colorWithHexString  sos_ColorWithHexString

 NS_INLINE NSBundle * SOSSkinBundlePath(void) {
      NSString *bundlePath = [[ NSBundle SOSBundle] pathForResource:@"SOSSkinResource" ofType:@"bundle"];
           NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    return bundle;
}

@interface UIColor (common)

+ (UIColor*)Gray246;
+ (UIColor*)Gray238;
+ (UIColor*)Gray185;
+ (UIColor*)Gray129;
+ (UIColor*)LineGray;
+ (UIColor*)Gray153;
+ (UIColor*)Gray102;
+ (UIColor*)Gray78;
+ (UIColor*)Gray52;
+ (UIColor*)skyBlue;
+ (UIColor*)cadiStytle;
+ (instancetype)sos_ColorWithHexString:(NSString *)hexStr;
+ (UIColor*)sos_skinColorWithKey:(NSString *)skinKey;
@end
