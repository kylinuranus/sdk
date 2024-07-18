//
//  SOSCarSecretaryCell.m
//  Onstar
//
//  Created by TaoLiang on 2018/1/30.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSCarSecretaryCell.h"
#import "SOSCarSecretaryPoint.h"

@interface SOSCarSecretaryCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) UILabel *point;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation SOSCarSecretaryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _point = [UILabel new];
    _point.text = @"*";
    _point.textColor = [UIColor colorWithHexString:@"#DF0000"];
    _point.font = [UIFont systemFontOfSize:11];
    
    _point.hidden = YES;    [self.contentView addSubview:_point];
    [_point mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerY.equalTo(_titleLabel);
        make.left.equalTo(_titleLabel.mas_right).offset(5);
        make.size.mas_equalTo(CGSizeMake(10, 10));
    }];

}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)setValue:(NSString *)value {
    _value = value;
    _timeLabel.text = value;
    _point.hidden = value.length > 0;

}

@end
