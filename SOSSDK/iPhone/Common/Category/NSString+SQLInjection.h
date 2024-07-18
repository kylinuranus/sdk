//
//  NSString+SQLInjection.h
//  Onstar
//
//  Created by TaoLiang on 2017/11/13.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SQLInjection)

///防止SQL注入
- (NSString *)transactSQLInjection;
- (BOOL)sql_inj:(NSString *)str;
@end
