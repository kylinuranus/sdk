//
//  SOSAboutAgreementView.m
//  Onstar
//
//  Created by TaoLiang on 14/05/2018.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSAboutAgreementView.h"

@interface SOSAboutAgreementView ()
@property (strong, nonatomic) UILabel *firstLabel;
@property (strong, nonatomic) UILabel *secondLabel;


@end

@implementation SOSAboutAgreementView


- (void)setAgreements:(NSMutableArray<SOSAgreement *> *)agreements {
    [super setAgreements:agreements];
    if (agreements.count < 4) {
        return;
    }
    NSString *line1 = [NSString stringWithFormat:@"《%@》、《%@》", agreements[0].docTitle, agreements[1].docTitle];
    NSString *line2 = [NSString stringWithFormat:@"《%@》、《%@》", agreements[2].docTitle, agreements[3].docTitle];
    self.firstLabel.text = line1;
    NSArray<NSValue *> *firstRanges = [self getRangesForAgreement:line1];
    __weak __typeof(self)weakSelf = self;
    [_firstLabel detectRanges:firstRanges tapped:^(NSInteger index) {
        if (weakSelf.tapAgreement) {
            weakSelf.tapAgreement(0, index);
        }
    }];
    self.secondLabel.text = line2;
    NSArray<NSValue *> *secondRanges = [self getRangesForAgreement:line2];
    [_secondLabel detectRanges:secondRanges tapped:^(NSInteger index) {
        if (weakSelf.tapAgreement) {
            weakSelf.tapAgreement(1, index);
        }
    }];
}

- (UILabel *)firstLabel {
    if (!_firstLabel) {
        _firstLabel = [UILabel new];
        _firstLabel.font = [UIFont systemFontOfSize:13];
        _firstLabel.textColor = [UIColor colorWithHexString:@"107FE0"];
        _firstLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_firstLabel];
        [_firstLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.right.top.equalTo(self);
        }];
    }
    return _firstLabel;
}

- (UILabel *)secondLabel {
    if (!_secondLabel) {
        _secondLabel = [UILabel new];
        _secondLabel.font = [UIFont systemFontOfSize:13];
        _secondLabel.textColor = [UIColor colorWithHexString:@"107FE0"];
        _secondLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_secondLabel];
        [_secondLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.right.bottom.equalTo(self);
            make.top.equalTo(_firstLabel.mas_bottom).offset(5);
        }];

    }
    return _secondLabel;
}


@end
