//
//  NSString+DiskCacheImage.m
//  imageTest
//
//  Created by jieke on 2019/7/25.
//  Copyright © 2019 jieke. All rights reserved.
//

#import "NSString+DiskCacheImage.h"
#import <SDWebImage/SDImageCache.h>

@implementation NSString (DiskCacheImage)

+ (UIImage *)getDiskCacheImage:(NSString *)imageFilePath {
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imageFilePath];
    return image;
}
@end
