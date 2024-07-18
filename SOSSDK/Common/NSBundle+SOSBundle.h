//
//  NSBundle+SOSBundle.h
//  Onstar
//
//  Created by onstar on 2018/1/10.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NSLocalizedString(key, comment) \
[[NSBundle SOSBundle] localizedStringForKey:(key) value:@"" table:nil]



@interface NSBundle (SOSBundle)
+ (NSBundle *)SOSBundle;
@end
