//
//  OwnerLifeHotActivityCell.m
//  Onstar
//
//  Created by Apple on 17/1/5.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "OwnerLifeHotActivityCell.h"
#import "Masonry.h"
#import "UIImageView+WebCache.h"

@interface OwnerLifeHotActivityCell ()
@property (retain, nonatomic) UIImageView *imgV;
@end

@implementation OwnerLifeHotActivityCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imgV = [[UIImageView alloc] init];
        [self addSubview:_imgV];
        [_imgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self).insets(UIEdgeInsetsMake(0, 15, 0, 15));
        }];
        
    }
    return self;
}

- (void)setHotActivity:(NNBanner *)hotActivity
{
    _hotActivity = hotActivity;
    [_imgV sd_setImageWithURL:[NSURL URLWithString:_hotActivity.imgUrl] placeholderImage:[UIImage imageNamed:@"图片加载失败大"]];
}


@end
