//
//  NSString+DiskCacheImage.h
//  imageTest
//
//  Created by jieke on 2019/7/25.
//  Copyright © 2019 jieke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (DiskCacheImage)

+ (UIImage *)getDiskCacheImage:(NSString *)imageFilePath;

@end

