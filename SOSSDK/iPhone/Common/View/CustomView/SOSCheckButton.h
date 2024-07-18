//
//  SOSCheckButton.h
//  Onstar
//
//  Created by TaoLiang on 02/05/2018.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSCheckButton : UIButton

/**
 生成button

 @param imageNames 图片数量不能为1，可以为0用默认图片或者大于2取前两个
 @return button
 */
+ (instancetype)buttonWithImageNames:(NSArray<NSString *> *)imageNames;
@end
