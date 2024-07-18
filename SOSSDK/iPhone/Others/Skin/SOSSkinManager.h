//
//  SOSSkinManager.h
//  Onstar
//
//  Created by Onstar on 2019/12/19.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSSkinManager : NSObject
+(NSString *)skinDocumentsPath;
+( BOOL )hasNewSkin;
@end

NS_ASSUME_NONNULL_END
