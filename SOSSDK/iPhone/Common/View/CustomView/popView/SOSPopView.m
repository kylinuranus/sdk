//
//  SOSPopView.m
//  Onstar
//
//  Created by onstar on 2018/1/30.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSPopView.h"

@interface SOSPopView ()

@property (nonatomic, copy) void(^tapImageViewBlock)(void);

@end

@implementation SOSPopView

+ (instancetype)quickInit {
    id view = [[NSBundle SOSBundle] loadNibNamed:self.className owner:nil options:nil].firstObject;
    return view;
}

- (IBAction)buttonClick:(id)sender {
    [self dismiss];
}

- (void)showInView:(UIView *)superView
       imgTapBlock:(void(^)(void))tapBlock{
    [superView addSubview:self];
//    [self mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(superView);
//    }];
    self.frame = CGRectMake(0, 0, superView.width, superView.height);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self.imageView addGestureRecognizer:tap];
    self.imageView.userInteractionEnabled = YES;
    self.tapImageViewBlock = tapBlock;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [self viewWithTag:100];
    }
    return _imageView;
}

- (void)onTap:(UITapGestureRecognizer *)tap {
    if (self.tapImageViewBlock) {
        self.tapImageViewBlock();
    }
}

- (void)dismiss {
    [self removeFromSuperview];
}

@end
