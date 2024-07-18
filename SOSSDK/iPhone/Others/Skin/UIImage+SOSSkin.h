//
//  UIImage+SOSSkin.h
//  Onstar
//
//  Created by Onstar on 2019/12/19.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (SOSSkin)

+ (nullable UIImage *)sossk_imageNamed:(NSString *)name;
+ (nullable UIImage *)sosSDK_imageNamed:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
