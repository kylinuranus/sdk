//
//  OwnerLifeHeaderView.m
//  Onstar
//
//  Created by Apple on 17/1/5.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "OwnerLifeHeaderView.h"
#import "Masonry.h"

@interface OwnerLifeHeaderView ()
@property (retain, nonatomic) UIView *leftView;
@property (retain, nonatomic) UILabel *headerTitleLabel;
@end

@implementation OwnerLifeHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _leftView = [[UIView alloc] init];
        _leftView.backgroundColor = [UIColor colorWithHexString:@"107fe0"];
        [self addSubview:_leftView];
        [_leftView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(20);
            make.size.mas_equalTo(CGSizeMake(2, 13));
            make.left.offset(15);
        }];

        _headerTitleLabel = [[UILabel alloc] init];
        _headerTitleLabel.textColor = [UIColor colorWithHexString:@"131329"];
        _headerTitleLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:_headerTitleLabel];
        [_headerTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_leftView.mas_right).offset(8);
            make.right.offset(-15);
            make.height.equalTo(@15);
            make.top.offset(20);
        }];
    }
    return self;
}

- (void)setHeaderTitle:(NSString *)headerTitle
{
    _headerTitle = headerTitle;
    _headerTitleLabel.text = _headerTitle;
}

@end
