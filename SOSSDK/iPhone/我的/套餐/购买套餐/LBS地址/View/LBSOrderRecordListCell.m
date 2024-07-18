//
//  LBSOrderRecordListCell.m
//  ListTest
//
//  Created by jieke on 2019/6/19.
//  Copyright © 2019 jieke. All rights reserved.
//

#import "LBSOrderRecordListCell.h"
#import "UIView+Radius.h"
#import "LBSOrderRecordListModel.h"
#import "ScreenInfo.h"
#import "NSString+Category.h"

@interface LBSOrderRecordListCell ()

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
@property (nonatomic, strong) UIButton *showMoreBtn;

/** 下面的子视图 */

@property (nonatomic, strong) UIView *bottomWhiteView;
@property (nonatomic, strong) UIView *bottomTopLineView;
@property (nonatomic, strong) UIView *leftLineView;
@property (nonatomic, strong) UILabel *bottomTopLabel;
@property (nonatomic, strong) UILabel *expressCompanyDesLabel;
@property (nonatomic, strong) UILabel *expressOrderNumberDesLabel;
@property (nonatomic, strong) UILabel *expressCompanyLabel;
@property (nonatomic, strong) UILabel *expressOrderNumberLabel;
@property (nonatomic, strong) UIButton *cpExpressNumberBtn;

@end

@implementation LBSOrderRecordListCell

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
        [self setupTopLayoutView];
        [self setupBottomLayoutView];
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    [UIView setupAllAroundRadius:self.backView];
}
#pragma mark - Private
- (void)setupTopLayoutView {
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
        //        make.bottom.mas_equalTo(0);
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
        //        make.bottom.mas_equalTo(-11);
    }];
    
    [self.topWhiteView addSubview:self.showMoreBtn];
    [self.showMoreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.orderNumberLabel.mas_bottom).offset(15);
        make.right.mas_equalTo(self.stateLabel);
        make.bottom.mas_equalTo(-6);
        make.size.mas_equalTo(CGSizeMake(34, 34));
    }];
}
- (void)setupBottomLayoutView {
    [self.backView addSubview:self.bottomWhiteView];
    [self.bottomWhiteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.topWhiteView);
        make.right.mas_equalTo(self.topWhiteView);
        make.top.mas_equalTo(self.topWhiteView.mas_bottom).offset(0);
        make.bottom.mas_equalTo(0);
    }];
    
    [self.bottomWhiteView addSubview:self.bottomTopLineView];
    [self.bottomTopLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo([[ScreenInfo sharedInstance] getBorderWidth:0.5]);
    }];
    
    [self.bottomWhiteView addSubview:self.leftLineView];
    [self.leftLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bottomTopLineView.mas_bottom).offset(20);
        make.left.mas_equalTo(16);
        make.width.mas_equalTo(4);
        make.height.mas_equalTo(16);
    }];
    
    [self.bottomWhiteView addSubview:self.bottomTopLabel];
    [self.bottomTopLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftLineView.mas_right).offset(8);
        make.centerY.mas_equalTo(self.leftLineView.mas_centerY);
        make.width.mas_greaterThanOrEqualTo(20);
    }];
    
    [self.expressCompanyDesLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.bottomWhiteView addSubview:self.expressCompanyDesLabel];
    [self.bottomWhiteView addSubview:self.expressCompanyLabel];
    [self.expressCompanyDesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftLineView);
        make.top.mas_equalTo(self.leftLineView.mas_bottom).offset(17);
        make.width.mas_greaterThanOrEqualTo(20);
    }];
    [self.expressCompanyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.expressCompanyDesLabel.mas_right).offset(5);
        make.right.mas_equalTo(-16);
        make.top.mas_equalTo(self.expressCompanyDesLabel);
    }];
    
    [self.expressOrderNumberDesLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.bottomWhiteView addSubview:self.expressOrderNumberDesLabel];
    [self.expressOrderNumberDesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.expressCompanyDesLabel);
        make.top.mas_equalTo(self.expressCompanyDesLabel.mas_bottom).offset(12);
        make.width.mas_greaterThanOrEqualTo(20);
        make.bottom.mas_equalTo(-16);
    }];
    
    [self.bottomWhiteView addSubview:self.expressOrderNumberLabel];
    [self.bottomWhiteView addSubview:self.cpExpressNumberBtn];
    [self.cpExpressNumberBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.expressCompanyLabel);
        make.bottom.mas_equalTo(self.expressOrderNumberDesLabel);
        make.width.mas_greaterThanOrEqualTo(20);
        make.height.mas_equalTo(20);
    }];
    [self.expressOrderNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.expressOrderNumberDesLabel.mas_right).offset(5);
        make.right.mas_equalTo(self.cpExpressNumberBtn.mas_left).offset(-10);
        make.top.mas_equalTo(self.expressOrderNumberDesLabel);
        make.bottom.mas_equalTo(self.expressOrderNumberDesLabel);
    }];
}
#pragma mark 复制订单号
- (void)cpExpressNumberBtnClick:(UIButton *)button {
    if (![NSString isBlankString:self.expressOrderNumberLabel.text]) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.expressOrderNumberLabel.text;
        [Util toastWithMessage:@"复制成功"];
    }
}
#pragma mark 点击查看更多
- (void)showMoreBtnClick:(UIButton *)button {
    button.selected = !button.selected;
    self.orderRecordListModel.openSection = button.selected;
    if (self.showMoreAction) {
        self.showMoreAction();
    }
}
- (void)setOrderRecordListModel:(LBSOrderRecordListModel *)orderRecordListModel {
    _orderRecordListModel = orderRecordListModel;
    self.showMoreBtn.selected = orderRecordListModel.openSection;
    
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
    self.expressOrderNumberLabel.text = orderRecordListModel.expressNumber;
    self.expressOrderNumberDesLabel.text = @"快递单号";
    self.expressCompanyLabel.text = orderRecordListModel.expressCompany;
    self.expressCompanyDesLabel.text = @"快递公司";
    self.bottomTopLabel.text = @"快递信息";
    [self setupMoneyLabelAttributedText];
}
#pragma mark 设置金钱富文本
- (void)setupMoneyLabelAttributedText {
    NSString *leftString = @"¥  ";
    NSString *rightString = self.orderRecordListModel.actualPrice;
    NSString *string = [NSString stringWithFormat:@"%@%@", leftString, rightString];
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc]initWithString:string];
    NSRange leftRange = NSMakeRange(0, leftString.length);
    [attributedStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:leftRange];
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
- (UIButton *)showMoreBtn {
    if (!_showMoreBtn) {
        _showMoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_showMoreBtn setImage:[UIImage imageNamed:@"lbs_down"] forState:UIControlStateNormal];
        [_showMoreBtn addTarget:self action:@selector(showMoreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _showMoreBtn.transform = CGAffineTransformMakeRotation(M_PI);
    }
    return _showMoreBtn;
}
#pragma mark 下面的
- (UIView *)bottomWhiteView {
    if (!_bottomWhiteView) {
        _bottomWhiteView = [[UIView alloc] init];
        _bottomWhiteView.backgroundColor = [UIColor clearColor];
    }
    return _bottomWhiteView;
}
- (UIView *)bottomTopLineView {
    if (!_bottomTopLineView) {
        _bottomTopLineView = [[UIView alloc] init];
        _bottomTopLineView.backgroundColor = UIColorHex(0xF3F3F4);
    }
    return _bottomTopLineView;
}
- (UIView *)leftLineView {
    if (!_leftLineView) {
        _leftLineView = [[UIView alloc] init];
        _leftLineView.backgroundColor = UIColorHex(0x6896ED);
    }
    return _leftLineView;
}
- (UILabel *)bottomTopLabel {
    if (!_bottomTopLabel) {
        _bottomTopLabel = [[UILabel alloc] init];
        _bottomTopLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size: 13];
        _bottomTopLabel.backgroundColor = [UIColor clearColor];
        _bottomTopLabel.textColor = UIColorHex(0x6896ED);
    }
    return _bottomTopLabel;
}
- (UILabel *)expressCompanyDesLabel {
    if (!_expressCompanyDesLabel) {
        _expressCompanyDesLabel = [[UILabel alloc] init];
        _expressCompanyDesLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 13];
        _expressCompanyDesLabel.backgroundColor = [UIColor clearColor];
        _expressCompanyDesLabel.textColor = UIColorHex(0x4E5059);
    }
    return _expressCompanyDesLabel;
}
- (UILabel *)expressOrderNumberDesLabel {
    if (!_expressOrderNumberDesLabel) {
        _expressOrderNumberDesLabel = [[UILabel alloc] init];
        _expressOrderNumberDesLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 13];
        _expressOrderNumberDesLabel.backgroundColor = [UIColor clearColor];
        _expressOrderNumberDesLabel.textColor = UIColorHex(0x4E5059);
    }
    return _expressOrderNumberDesLabel;
}
- (UILabel *)expressCompanyLabel {
    if (!_expressCompanyLabel) {
        _expressCompanyLabel = [[UILabel alloc] init];
        _expressCompanyLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 13];
        _expressCompanyLabel.backgroundColor = [UIColor clearColor];
        _expressCompanyLabel.textColor = UIColorHex(0x828389);
        _expressCompanyLabel.textAlignment = NSTextAlignmentRight;
    }
    return _expressCompanyLabel;
}
- (UILabel *)expressOrderNumberLabel {
    if (!_expressOrderNumberLabel) {
        _expressOrderNumberLabel = [[UILabel alloc] init];
        _expressOrderNumberLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 13];
        _expressOrderNumberLabel.backgroundColor = [UIColor clearColor];
        _expressOrderNumberLabel.textColor = UIColorHex(0x828389);
        _expressOrderNumberLabel.textAlignment = NSTextAlignmentRight;
    }
    return _expressOrderNumberLabel;
}
- (UIButton *)cpExpressNumberBtn {
    if (!_cpExpressNumberBtn) {
        _cpExpressNumberBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cpExpressNumberBtn addTarget:self action:@selector(cpExpressNumberBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _cpExpressNumberBtn.backgroundColor = [UIColor clearColor];
        [_cpExpressNumberBtn setTitle:@"复制" forState:UIControlStateNormal];
        [_cpExpressNumberBtn setTitleColor:UIColorHex(0x3A81FF) forState:UIControlStateNormal];
        _cpExpressNumberBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 13];
    }
    return _cpExpressNumberBtn;
}
@end


