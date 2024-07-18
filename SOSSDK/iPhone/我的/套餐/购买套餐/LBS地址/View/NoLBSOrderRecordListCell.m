//
//  LBSOrderRecordListCell.m
//  ListTest
//
//  Created by jieke on 2019/6/19.
//  Copyright © 2019 jieke. All rights reserved.
//

#import "NoLBSOrderRecordListCell.h"
#import "LBSOrderRecordListModel.h"
#import "UIView+Radius.h"
#import "ScreenInfo.h"

@interface NoLBSOrderRecordListCell ()

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *topWhiteView;
@property (nonatomic, strong) UIView *topLineView;
@property (nonatomic, strong) UILabel *topLabel;
@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, strong) UILabel *dateDesLabel;
@property (nonatomic, strong) UILabel *orderNumberDesLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *orderNumberLabel;
@property (nonatomic, strong) UILabel *moneyLabel;

@end

@implementation NoLBSOrderRecordListCell

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
- (void)layoutSubviews {
    [super layoutSubviews];
    [UIView setupAllAroundRadius:self.backView];
}
#pragma mark - Private
- (void)setupLayoutView {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.backView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.width.mas_equalTo(kScreenWidth-24);
        make.top.mas_equalTo(12);
        make.bottom.mas_equalTo(0);
    }];
    
    [self.backView addSubview:self.topWhiteView];
    [self.topWhiteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    [self.topWhiteView addSubview:self.stateLabel];
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(-16);
        make.width.mas_greaterThanOrEqualTo(20);
        make.height.mas_equalTo(26);
    }];
    
    [self.topWhiteView addSubview:self.topLineView];
    [self.topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.stateLabel.mas_bottom).offset(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo([[ScreenInfo sharedInstance] getBorderWidth:0.5]);
    }];
    
    [self.topWhiteView addSubview:self.topLabel];
    [self.topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topLineView.mas_bottom).offset(17);
        make.left.mas_equalTo(14);
        make.right.mas_equalTo(-14);
    }];
    
    [self.dateDesLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.topWhiteView addSubview:self.dateDesLabel];
    [self.topWhiteView addSubview:self.dateLabel];
    [self.dateDesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.topLabel);
        make.top.mas_equalTo(self.topLabel.mas_bottom).offset(17);
        make.width.mas_greaterThanOrEqualTo(20);
    }];
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.dateDesLabel.mas_right).offset(5);
        make.right.mas_equalTo(self.stateLabel);
        make.top.mas_equalTo(self.dateDesLabel);
    }];
    
    [self.orderNumberDesLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.topWhiteView addSubview:self.orderNumberDesLabel];
    [self.topWhiteView addSubview:self.orderNumberLabel];
    [self.orderNumberDesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.dateDesLabel);
        make.top.mas_equalTo(self.dateDesLabel.mas_bottom).offset(12);
        make.width.mas_greaterThanOrEqualTo(20);
    }];
    [self.orderNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.orderNumberDesLabel.mas_right).offset(5);
        make.right.mas_equalTo(self.stateLabel);
        make.top.mas_equalTo(self.orderNumberDesLabel);
    }];
    
    [self.topWhiteView addSubview:self.moneyLabel];
    [self.moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.dateDesLabel);
        make.top.mas_equalTo(self.orderNumberDesLabel.mas_bottom).offset(20);
        make.width.mas_greaterThanOrEqualTo(20);
        make.bottom.mas_equalTo(-12);
    }];
}
- (void)setOrderRecordListModel:(LBSOrderRecordListModel *)orderRecordListModel {
    _orderRecordListModel = orderRecordListModel;
    
    NSString *status = orderRecordListModel.statusValue;
    if ([orderRecordListModel.statusValue isEqualToString:@"已支付"]) {
        status = @"已完成";
    }
    self.stateLabel.text = status;//orderRecordListModel.statusValue;
    self.topLabel.text = orderRecordListModel.offeringName;
    self.dateDesLabel.text = @"购买日期";
    self.orderNumberDesLabel.text = @"订单号";
    self.dateLabel.text = orderRecordListModel.createDate;
    self.orderNumberLabel.text = orderRecordListModel.buyOrderId;
    [self setupMoneyLabelAttributedText];
}
#pragma mark 设置金钱富文本
- (void)setupMoneyLabelAttributedText {
    NSString *leftString = @"¥  ";
    NSString *rightString = self.orderRecordListModel.actualPrice;
    NSString *string = [NSString stringWithFormat:@"%@%@", leftString, rightString];
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc]initWithString:string];
    NSRange leftRange = NSMakeRange(0, leftString.length);
    [attributedStr addAttribute:NSFontAttributeName value: [UIFont systemFontOfSize:15] range:leftRange];
    NSRange rightRange = NSMakeRange(leftString.length, rightString.length);
    [attributedStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:26] range:rightRange];
    self.moneyLabel.attributedText = attributedStr;
}
#pragma mark - 懒加载
- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] init];
        //        _backView.backgroundColor = UIColorHex(0xF3F5FE);
        _backView.backgroundColor = [UIColor whiteColor];
        //        _backView.layer.cornerRadius = 4.0;
        //        _backView.clipsToBounds = YES;
    }
    return _backView;
}
- (UIView *)topWhiteView {
    if (!_topWhiteView) {
        _topWhiteView = [[UIView alloc] init];
        _topWhiteView.backgroundColor = [UIColor clearColor];
    }
    return _topWhiteView;
}
- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] init];
        _stateLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 11];
        _stateLabel.backgroundColor = [UIColor clearColor];
        _stateLabel.textColor = UIColorHex(0xA4A4A4);
    }
    return _stateLabel;
}
- (UIView *)topLineView {
    if (!_topLineView) {
        _topLineView = [[UIView alloc] init];
        _topLineView.backgroundColor = UIColorHex(0xF3F3F4);
    }
    return _topLineView;
}
- (UILabel *)topLabel {
    if (!_topLabel) {
        _topLabel = [[UILabel alloc] init];
        _topLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size: 17];
        _topLabel.backgroundColor = [UIColor clearColor];
        _topLabel.textColor = UIColorHex(0x28292F);
    }
    return _topLabel;
}
- (UILabel *)dateDesLabel {
    if (!_dateDesLabel) {
        _dateDesLabel = [[UILabel alloc] init];
        _dateDesLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 13];
        _dateDesLabel.backgroundColor = [UIColor clearColor];
        _dateDesLabel.textColor = UIColorHex(0x4E5059);
    }
    return _dateDesLabel;
}
- (UILabel *)orderNumberDesLabel {
    if (!_orderNumberDesLabel) {
        _orderNumberDesLabel = [[UILabel alloc] init];
        _orderNumberDesLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 13];
        _orderNumberDesLabel.backgroundColor = [UIColor clearColor];
        _orderNumberDesLabel.textColor = UIColorHex(0x4E5059);
    }
    return _orderNumberDesLabel;
}
- (UILabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 13];
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.textColor = UIColorHex(0x828389);
        _dateLabel.textAlignment = NSTextAlignmentRight;
    }
    return _dateLabel;
}
- (UILabel *)orderNumberLabel {
    if (!_orderNumberLabel) {
        _orderNumberLabel = [[UILabel alloc] init];
        _orderNumberLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 13];
        _orderNumberLabel.backgroundColor = [UIColor clearColor];
        _orderNumberLabel.textColor = UIColorHex(0x828389);
        _orderNumberLabel.textAlignment = NSTextAlignmentRight;
    }
    return _orderNumberLabel;
}
- (UILabel *)moneyLabel {
    if (!_moneyLabel) {
        _moneyLabel = [[UILabel alloc] init];
        _moneyLabel.font = [UIFont systemFontOfSize:26];
        _moneyLabel.backgroundColor = [UIColor clearColor];
        _moneyLabel.textColor = UIColorHex(0x9D8169);
    }
    return _moneyLabel;
}
@end
