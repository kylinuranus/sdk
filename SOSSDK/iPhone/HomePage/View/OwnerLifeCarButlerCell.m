//
//  OwnerLifeCarButlerCell.m
//  Onstar
//
//  Created by Apple on 17/1/5.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "OwnerLifeCarButlerCell.h"
#import "Masonry.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"

@interface OwnerLifeCarButlerCell ()
@property (retain, nonatomic) UIImageView *imgV;
@property (retain, nonatomic) UILabel *titleLabel;
@end

@implementation OwnerLifeCarButlerCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imgV = [[UIImageView alloc] init];
//        _imgV.layer.cornerRadius = 25;
//        _imgV.clipsToBounds = YES;
        [self addSubview:_imgV];
        [_imgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50, 50));
            make.top.offset(5);
            make.centerX.equalTo(self);
        }];

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor colorWithHexString:@"131329"];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_imgV.mas_bottom).offset(7);
            make.right.offset(0);
            make.left.offset(0);
            make.height.mas_equalTo(30.0);
        }];
    }
//    self.backgroundColor = [UIColor redColor];
    return self;
}

- (void)setCarButler:(NNBanner *)carButler
{
    _carButler = carButler;
    _titleLabel.text = _carButler.title;
    [_imgV sd_setImageWithURL:[NSURL URLWithString:_carButler.imgUrl]];
}

@end
