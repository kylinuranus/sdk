//
//  SOSScanPhotoImage.h
//  Onstar
//
//  Created by Genie Sun on 2016/11/21.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOSScanPhotoImage : NSObject
/**
 *  浏览大图
 *
 *  @param scanImageView 图片所在的imageView
 */
+ (void)scanBigImageWithImageView:(UIButton *)currentImageview;

@end
