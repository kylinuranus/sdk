//
//  UIImage+SOSSkin.m
//  Onstar
//
//  Created by Onstar on 2019/12/19.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "UIImage+SOSSkin.h"



@implementation UIImage (SOSSkin)

+ (nullable UIImage *)sossk_imageNamed:(NSString *)name{
    if (SOS_APP_DELEGATE.useSkin) {
        NSBundle * bPath = SOSSkinBundlePath();
               NSString * suffix;
               CGFloat scale = [UIScreen mainScreen].scale;
               if (ABS(scale-3) <= 0.001) {
                  //@3x
                   suffix = @"@3x";
               }else {
                  //@2x
                   suffix = @"@2x";
               }
               
               NSString *img_path = [bPath pathForResource:[NSString stringWithFormat:@"%@%@",name,suffix] ofType:@"png"];
               
               UIImage * img = [self imageWithContentsOfFile:img_path];
               if (!img) {
                   img =[[self imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
               }
               return img;
       
    }else{
        return [[self imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
}
+ (nullable UIImage *)sosSDK_imageNamed:(NSString *)name{
    if (SOS_CD_PRODUCT) {
        name = [name stringByAppendingString:@"_sdkcd"];
    }
    if (SOS_BUICK_PRODUCT) {
           name = [name stringByAppendingString:@"_sdkbuick"];
       }
    return [[self imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
 
    
//    NSString * suffix;
//    CGFloat scale = [UIScreen mainScreen].scale;
//    if (ABS(scale-3) <= 0.001) {
//       //@3x
//        suffix = @"@3x";
//    }else {
//       //@2x
//        suffix = @"@2x";
//    }
//    suffix = @"@2x";
//
//    NSBundle *mainBundle= [NSBundle mainBundle];
//    NSString *img_path = [mainBundle pathForResource:[NSString stringWithFormat:@"%@%@",name,suffix] ofType:@"png"];
//
//    NSLog(@"mainBundle的名字=%@",mainBundle);
//    NSLog(@"mainBundle中图片的名字=%@",img_path);
//
//    UIImage * img = [self imageWithContentsOfFile:img_path];
//    if (!img) {
//        NSLog(@"图片的名字=%@",name);
//        img =[self imageNamed:name];
//    }
    
    
   // return img;
    
   // return [self imageNamed:name];

}
@end
