//
//  SOSCarAssessmentView.m
//  Onstar
//
//  Created by Genie Sun on 2016/11/10.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "SOSCarAssessmentView.h"

@implementation SOSCarAssessmentView

- (instancetype)initWithFrame:(CGRect)frame		{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)initView {
    switch (_carEnum) {
        case GOInCarReport:
            [self removeAllSubviews];
            [self addSubview:self.bgImageView];
            [self addSubview:self.titleBtn];
            [self addSubview:self.selBtn];
            [self addSubview:self.agreeBtnLb];
            [self addSubview:self.tipLabel];
            break;
        case ShareCarReport:
            [self removeAllSubviews];
            self.backgroundColor = [UIColor whiteColor];
            [self addSubview:self.tipImage];
            [self addSubview:self.tipLb];
            [self addSubview:self.selectButton];
            [self initAgreementBtn];
            [self addSubview:self.agreementBtn];
            [self addSubview:self.shareBtn];
            break;
        default:
            break;
    }
    [self fixFrame];
}

- (UIButton *)titleBtn	{
    if (!_titleBtn) {
        _titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_titleBtn setTitle:@"进入报告" forState:UIControlStateNormal];
        [_titleBtn setTitleColor:[UIColor colorWithHexString:@"5D83FF"] forState:UIControlStateNormal];
        _titleBtn.titleLabel.font = [UIFont systemFontOfSize:19.f];
        [_titleBtn addTarget:self action:@selector(pushReport:) forControlEvents:UIControlEventTouchUpInside];
        _titleBtn.backgroundColor = [UIColor whiteColor];
        _titleBtn.layer.cornerRadius = 3.f;
        _titleBtn.layer.masksToBounds = YES;
        self.Flag = YES;
        _titleBtn.frame = CGRectMake(35.f,(IS_IPHONE_5 || IS_IPHONE_4_OR_LESS)? self.height - 103.f + 30.f: self.height - 93.f, self.width - 70.f, 40.f);
    }
    return _titleBtn;
}

- (UIImageView *)bgImageView	{
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.width, self.height)];
        _bgImageView.image = [UIImage imageNamed:@"弹框2"];
    }
    return _bgImageView;
}

- (UIView *)maskView	{
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:[[UIApplication sharedApplication].windows lastObject].bounds];
        _maskView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.400];
        _maskView.alpha = 0.f;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backVc)];
        [_maskView addGestureRecognizer:tap];
    }
    return _maskView;
}

- (void)backVc	{
    [self dismissShareReportView];
}

- (UILabel *)tipLabel	{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.f, (IS_IPHONE_5 || IS_IPHONE_4_OR_LESS) ? self.height - 15.f : self.height - 25.f, self.width -20, 10.f)];
        _tipLabel.font = [UIFont systemFontOfSize:10.f];
        _tipLabel.textColor = [UIColor colorWithHexString:@"FFFFFF"];
        _tipLabel.text = @"提示：同意爱车评估服务条款以分享报告给微信好友";
        _tipLabel.adjustsFontSizeToFitWidth = YES;
        _tipLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tipLabel;
}


- (UIButton *)selBtn	{
    if (!_selBtn) {
        _selBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selBtn setImage:[UIImage imageNamed:@"同意"] forState:UIControlStateSelected];
        [_selBtn setImage:[UIImage imageNamed:@"同意bg"] forState:UIControlStateNormal];
        [_selBtn addTarget:self action:@selector(agreeSelect:) forControlEvents:UIControlEventTouchUpInside];
        _selBtn.frame = CGRectMake((IS_IPHONE_5 || IS_IPHONE_4_OR_LESS) ? 40 : 80.f, (IS_IPHONE_5 || IS_IPHONE_4_OR_LESS) ?  self.height - 29.f : self.height - 49.f, 12.f, 12.f);
        _selBtn.selected = YES;
    }
    return _selBtn;
}

- (UIButton *)agreeBtnLb	{
    if (!_agreeBtnLb) {
        _agreeBtnLb = [UIButton buttonWithType:UIButtonTypeCustom];
        [_agreeBtnLb setTintColor:[UIColor colorWithHexString:@"FFFFFF"]];
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:@"同意《爱车评估服务条款》"];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"1495EB"] range:NSMakeRange(2, attributeStr.length - 2)];
        [_agreeBtnLb setAttributedTitle:attributeStr forState:UIControlStateNormal];
        _agreeBtnLb.titleLabel.font = [UIFont systemFontOfSize:11.f];
        _agreeBtnLb.frame = CGRectMake(self.selBtn.left + self.selBtn.width * 1.5,(IS_IPHONE_5 || IS_IPHONE_4_OR_LESS) ?  self.height - 25.f: self.height - 46, 150.f, 10.f);
        _agreeBtnLb.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _agreeBtnLb.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_agreeBtnLb addTarget:self action:@selector(pushAgreeementUrl) forControlEvents:UIControlEventTouchUpInside];
    }
    return _agreeBtnLb;
}

- (void)pushReport:(UIButton *)sender	{
    if (self.agreeGoInAction) {
        self.agreeGoInAction(self.Flag);
    }
    if (self.Flag) {
        [SOSDaapManager sendActionInfo:CarAssmt_EnterReportWithProtocolChecked];
    }else {
        [SOSDaapManager sendActionInfo:CarAssmt_EnterReportWithProtocolUnchecked];
    }
    
    [self dismissShareReportView];
}

- (void)agreeSelect:(UIButton *)sender	{
    sender.selected = ! sender.selected;
    if (_carEnum == GOInCarReport) {
        if (sender.selected)	self.Flag = YES;
        else					self.Flag = NO;
    }	else if (_carEnum == ShareCarReport)	{
        if (sender.selected)		_shareBtn.enabled = YES;
        else						_shareBtn.enabled = NO;
    }
}


- (UIImageView *)tipImage	{
    if (!_tipImage) {
        _tipImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"提示"]];
        _tipImage.frame = CGRectMake(15.f, 30.f, 15.f, 15.f);
    }
    return _tipImage;
}

- (UILabel *)tipLb	{
    if (!_tipLb) {
        _tipLb = [[UILabel alloc] initWithFrame:CGRectMake(self.tipImage.frame.size.width + 20.f, self.tipImage.frame.origin.y, self.width - 40, 15.f)];
        _tipLb.text = @"同意爱车评估服务条款以分享报告到微信";
        _tipLb.adjustsFontSizeToFitWidth = YES;
        _tipLb.textColor = [UIColor colorWithHexString:@"131329"];
        _tipLb.font = [UIFont systemFontOfSize:14.f];
    }
    return _tipLb;
}

- (UIButton *)selectButton	{
    if (!_selectButton) {
        _selectButton = [UIButton buttonWithType:0];
        [_selectButton setImage:[UIImage imageNamed:@"同意-1"] forState:UIControlStateSelected];
        [_selectButton setImage:[UIImage imageNamed:@"不同意"] forState:UIControlStateNormal];
        [_selectButton addTarget:self action:@selector(agreeSelect:) forControlEvents:UIControlEventTouchUpInside];
        _selectButton.frame = CGRectMake(IS_IPHONE_5 ? 40.f : 80.f, 80.f, 12.f, 12.f);
        _selectButton.selected = YES;
    }
    return _selectButton;
}

- (void)initAgreementBtn		{
    if (!_agreementBtn) {
        _agreementBtn = [UIButton buttonWithType:0];
        [_agreementBtn setTitleColor:[UIColor colorWithHexString:@"131329"] forState:0];
        _agreementBtn.frame = CGRectMake(self.selectButton.right + 5, self.selectButton.top, 160, 15.f);
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:@"同意《爱车评估服务条款》"];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"1495EB"] range:NSMakeRange(2, attributeStr.length - 2)];
        [_agreementBtn setAttributedTitle:attributeStr forState:UIControlStateNormal];
        _agreementBtn.titleLabel.font = [UIFont systemFontOfSize:13.f];
        _agreementBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_agreementBtn addTarget:self action:@selector(pushAgreeementUrl) forControlEvents:UIControlEventTouchUpInside];
        _agreementBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
}

- (void)fixFrame    {
    if (self.carEnum == GOInCarReport)    {
        self.selBtn.left = (self.width - self.selBtn.width - 5 - self.agreeBtnLb.width) / 2.f - 5;
        self.agreeBtnLb.left = self.selBtn.right + 5;
    }	else if (self.carEnum == ShareCarReport) {
        self.selectButton.left = (self.width - self.selectButton.width - 5 - self.agreementBtn.width) / 2.f - 5;
        self.agreementBtn.left = self.selectButton.right + 5;
    }
}

- (UIButton *)shareBtn	{
    if (!_shareBtn) 		{
        _shareBtn = [UIButton buttonWithType:0];
        _shareBtn.frame = CGRectMake(0, self.agreementBtn.frame.origin.y + 45.f, self.width, 45.f);
        [_shareBtn setBackgroundColor:[UIColor colorWithHexString:@"2683DA"] forState:0];
        [_shareBtn setTitleColor:[UIColor colorWithHexString:@"FFFFFF"] forState:0];
        [_shareBtn setTitle:@"分享报告" forState:0];
        _shareBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
        _shareBtn.enabled = NO;
        [_shareBtn addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
        _shareBtn.enabled = YES;
    }
    return _shareBtn;
}

- (void)share {
    if (self.agreeGoInAction)		self.agreeGoInAction(self.shareBtn.enabled);
    [self dismissShareReportView];
}

#pragma mark - showAlertView
- (void)showShareReportView {
    if (self.superview) 	return;
    UIWindow *keyWindow = SOS_ONSTAR_WINDOW;
    [keyWindow addSubview:self.maskView];
    [keyWindow addSubview:self];
    self.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    [UIView animateWithDuration:0.25 animations:^{
        self.maskView.alpha = 1.f;
        self.alpha = 1.f;
        self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - dismissAlertView
- (void)dismissShareReportView {
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0.f;
        self.maskView.alpha = 0.f;
        self.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    }completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
            [self.maskView removeFromSuperview];
        }
    }];
}

- (void)pushAgreeementUrl	{
    if (self.agreementUrl)		self.agreementUrl();
}
@end
