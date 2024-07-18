//
//  LBSConfirmOrderCell.m
//  LBSTest
//
//  Created by jieke on 2019/6/13.
//  Copyright © 2019 jieke. All rights reserved.
//

#import "LBSConfirmOrderSetMealCell.h"
#import "ScreenInfo.h"

@interface LBSConfirmOrderSetMealCell () <BaseTableViewCellProtocol>

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *rightLabel;
@property (nonatomic, strong) UIView *lineView;
@end

@implementation LBSConfirmOrderSetMealCell

#pragma mark - 系统的
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupLayoutView];
    }
    return self;
}
#pragma mark - BaseTableViewCellProtocol
- (void)configModel:(id)model {
    NSDictionary *dict = model;
    self.leftLabel.text = dict.allKeys.firstObject;
    self.rightLabel.text = dict.allValues.firstObject;
}

#pragma mark - Private
- (void)setupLayoutView {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self addSubview:self.backView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(55);
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
    
    [self.backView addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo([[ScreenInfo sharedInstance] getBorderWidth:0.5]);
    }];
    
    [self.leftLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.backView addSubview:self.leftLabel];
    [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.top.mas_equalTo(self.lineView.mas_bottom).offset(0);
        make.width.mas_greaterThanOrEqualTo(20);
        make.bottom.mas_equalTo(0);
    }];
    
    [self.backView addSubview:self.rightLabel];
    [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftLabel.mas_right).offset(16);
        make.top.mas_equalTo(self.leftLabel);
        make.right.mas_equalTo(-16);
        make.bottom.mas_equalTo(self.leftLabel);
    }];
    
}
#pragma mark - 懒加载
- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = [UIColor clearColor];
    }
    return _backView;
}
- (UILabel *)leftLabel {
    if (!_leftLabel) {
        _leftLabel = [[UILabel alloc] init];
        _leftLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
        _leftLabel.backgroundColor = [UIColor clearColor];
        _leftLabel.textColor = UIColorHex(0x28292F);
    }
    return _leftLabel;
}
- (UILabel *)rightLabel {
    if (!_rightLabel) {
        _rightLabel = [[UILabel alloc] init];
        _rightLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
        _rightLabel.backgroundColor = [UIColor clearColor];
        _rightLabel.textColor = UIColorHex(0x828389);
    }
    return _rightLabel;
}
- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = UIColorHex(0xf3f3f4);
    }
    return _lineView;
}
@end

