//
//  UILabel+DetectLink.h
//  Onstar
//
//  Created by TaoLiang on 02/05/2018.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (DetectLink)
- (void)detectRanges:(NSArray<NSValue *> *)ranges tapped:(void(^)(NSInteger index))tapped;
@end
