//
//  LBSConsigneeCell.m
//  LBSTest
//
//  Created by jieke on 2019/6/13.
//  Copyright © 2019 jieke. All rights reserved.
//

#import "LBSConsigneeCell.h"
#import "NSAttributedString+Category.h"
#import "ScreenInfo.h"
#import "NSString+Category.h"

static NSUInteger const maxCount = 12;

@interface LBSConsigneeCell () <BaseTableViewCellProtocol>

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *starsLabel;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIView *lineView;
@end

@implementation LBSConsigneeCell

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
    PackageInfos *packageInfos = model;
    self.leftLabel.text = packageInfos.name;
    self.textField.attributedPlaceholder = [NSAttributedString setAttributedStringTitle:packageInfos.placeholder placeholderColor:UIColorHex(0x828389) textFieldFont:self.textField.font];
}

#pragma mark - Private
- (void)setupLayoutView {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self addSubview:self.backView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
    
    [self.leftLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.backView addSubview:self.leftLabel];
    [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.top.mas_equalTo(0);
        make.width.mas_greaterThanOrEqualTo(20);
        make.bottom.mas_equalTo(0);
    }];
    
    [self.backView addSubview:self.starsLabel];
    [self.starsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftLabel.mas_right).offset(4);
        make.width.mas_equalTo(10);
        make.top.mas_equalTo(self.leftLabel);
        make.bottom.mas_equalTo(self.leftLabel);
    }];
    
    [self.backView addSubview:self.textField];
    [self.backView addSubview:self.closeBtn];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.starsLabel.mas_right).offset(6);
        make.right.mas_equalTo(self.closeBtn.mas_left).offset(-5);
        make.top.mas_equalTo(self.leftLabel);
        make.bottom.mas_equalTo(self.leftLabel);
    }];
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-12);
        make.centerY.mas_equalTo(self.backView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(34, 34));
    }];
    
    [self.backView addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo([[ScreenInfo sharedInstance] getBorderWidth:0.5]);
    }];
    self.closeBtn.hidden = [NSString isBlankString:self.textField.text];
}
#pragma mark 监听文本输入
- (void)changeTextField:(UITextField *)textField {
    self.closeBtn.hidden = [NSString isBlankString:self.textField.text];
    if (self.tag == 1 && textField.markedTextRange == nil && textField.text.length > maxCount) {
        if (textField.text.length > maxCount) {
            textField.text = [textField.text substringToIndex:maxCount];
        }
    }
    if (self.changeTextFieldBlock) {
        self.changeTextFieldBlock(textField.text);
    }
}
#pragma mark 关闭按钮事件
- (void)closeBtnClick:(UIButton *)button {
    self.textField.text = @"";
    self.closeBtn.hidden = [NSString isBlankString:self.textField.text];
    if (self.changeTextFieldBlock) {
        self.changeTextFieldBlock(self.textField.text);
    }
}

#pragma mark - 更改textField内容 设置closeBtn hidden
- (void)setShowText:(NSString *)text {
    self.textField.text = text;
    self.closeBtn.hidden = [NSString isBlankString:self.textField.text];
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
- (UILabel *)starsLabel {
    if (!_starsLabel) {
        _starsLabel = [[UILabel alloc] init];
        _starsLabel.font = [UIFont fontWithName:@"PingFang-SC-Medium" size: 11];
        _starsLabel.backgroundColor = [UIColor clearColor];
        _starsLabel.textColor = UIColorHex(0xDF0000);
        _starsLabel.text = @"*";
    }
    return _starsLabel;
}
- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] initWithFrame:CGRectZero];
//        _textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        _textField.backgroundColor = [UIColor clearColor];
        _textField.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
        [_textField addTarget:self action:@selector(changeTextField:) forControlEvents:UIControlEventEditingChanged];
//        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.textColor = UIColorHex(0x828389);
    }
    return _textField;
}
- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.hidden = YES;
        [_closeBtn setImage:[UIImage imageNamed:@"lbs_close"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}
- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = UIColorHex(0xf3f3f4);
    }
    return _lineView;
}


@end
