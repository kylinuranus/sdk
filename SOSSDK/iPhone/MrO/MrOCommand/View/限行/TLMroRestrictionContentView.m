//
//  TLMroRestrictionContentView.m
//  Onstar
//
//  Created by TaoLiang on 2017/11/23.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "TLMroRestrictionContentView.h"

@interface TLMroRestrictionContentView ()
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *contentLabel;


@end

@implementation TLMroRestrictionContentView

- (instancetype)init
{
    self = [super init];
    if (self) {
        static CGFloat padding = 15.f;
        _titleLabel = [UILabel new];
        _titleLabel.textColor = [UIColor lightGrayColor];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        [_titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        _titleLabel.textAlignment = NSTextAlignmentJustified;
        [self addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.mas_equalTo(padding);
            make.top.equalTo(@5);
            make.right.mas_equalTo(-padding);
        }];
        
        _contentLabel = [UILabel new];
        [_contentLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        _contentLabel.textColor = [UIColor purpleColor];
        _contentLabel.font = [UIFont systemFontOfSize:12];
        _contentLabel.numberOfLines = 0;
        _contentLabel.textAlignment = NSTextAlignmentJustified;
        _contentLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 70;
        [self addSubview:_contentLabel];
        [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(_titleLabel.mas_bottom).offset(5);
            make.left.mas_equalTo(padding);
            make.right.mas_equalTo(-padding);
            make.bottom.mas_equalTo(-5);
        }];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)setContent:(NSString *)content {
    _content = content;
    _contentLabel.text = content;
}

@end
