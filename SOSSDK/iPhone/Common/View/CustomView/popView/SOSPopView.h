//
//  SOSPopView.h
//  Onstar
//
//  Created by onstar on 2018/1/30.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSPopView : UIView

@property (strong, nonatomic) UIImageView *imageView;

+ (instancetype)quickInit;

- (void)showInView:(UIView *)superView
       imgTapBlock:(void(^)(void))tapBlock;

- (void)dismiss;

@end
