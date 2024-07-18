//
//  SOSCycleBannerViewCell.m
//  Onstar
//
//  Created by Onstar on 2018/10/16.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSCycleBannerViewCell.h"

NSString *const SOSBannerReuseIdentifier = @"bannerCell";

@implementation SOSCycleBannerViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addImageView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self addImageView];
    }
    return self;
}

- (void)addImageView {
    UIImageView *imageV = [[UIImageView alloc]init];
    imageV.contentMode = UIViewContentModeScaleToFill;
    imageV.backgroundColor = [UIColor whiteColor];
    imageV.clipsToBounds = YES;
    [self addSubview:imageV];
    _imageView = imageV;
    @weakify(self);
    [imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.edges.mas_equalTo(self);
    }];
    
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor colorWithWhite:0 alpha:0.45];
    label.textColor = UIColor.whiteColor;
    label.font = [UIFont systemFontOfSize:11];
    label.layer.cornerRadius = 2;
    label.layer.masksToBounds = YES;
    [self addSubview:label];
    _indexLabel = label;
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(6);
        make.bottom.mas_equalTo(-4);
    }];
}

@end
