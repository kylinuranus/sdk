//
//  SOSCarSecretaryECCell.m
//  Onstar
//
//  Created by TaoLiang on 2018/1/29.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSCarSecretaryECCell.h"
#import "SOSCarSecretaryPoint.h"

@interface SOSCarSecretaryECCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;
//@property (strong, nonatomic) SOSCarSecretaryPoint *point;
@property (strong, nonatomic) UILabel *point;
@property (copy, nonatomic) NSString *editedValue;
@end

@implementation SOSCarSecretaryECCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _textField.textColor = [UIColor colorWithHexString:@"#828389"];
    
    _point = [UILabel new];
    _point.text = @"*";
    _point.textColor = [UIColor colorWithHexString:@"#DF0000"];
    _point.font = [UIFont systemFontOfSize:11];
    //    _point = [SOSCarSecretaryPoint point];
    _point.hidden = YES;
    [self.contentView addSubview:_point];
    [_point mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerY.equalTo(_titleLabel);
        make.left.equalTo(_titleLabel.mas_right).offset(5);
        make.size.mas_equalTo(CGSizeMake(10, 10));
    }];
    
    [_textField.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
        _point.hidden = x.length > 0;
        _value = x;
        _editedValue = x;
    }];
    
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
    if ([title containsString:@"姓"]) {
        _textField.placeholder = @"请输入姓氏";
        _textField.keyboardType = UIKeyboardTypeDefault;
        [_textField setBlockForControlEvents:UIControlEventEditingDidEnd block:^(id  _Nonnull sender) {
            [SOSDaapManager sendActionInfo:VehicleSec_emergencycontact_lastname];
        }];
    }else if ([title containsString:@"名"]) {
        _textField.placeholder = @"请输入名字";
        _textField.keyboardType = UIKeyboardTypeDefault;
        [_textField setBlockForControlEvents:UIControlEventEditingDidEnd block:^(id  _Nonnull sender) {
            [SOSDaapManager sendActionInfo:VehicleSec_emergencycontact_firstname];
        }];
    }else if ([title isEqualToString:@"联系电话"]) {
        _textField.placeholder = @"请输入联系号码";
        _textField.keyboardType = UIKeyboardTypeNumberPad;
        [_textField setBlockForControlEvents:UIControlEventEditingDidEnd block:^(id  _Nonnull sender) {
            [SOSDaapManager sendActionInfo:VehicleSec_emergencycontact_mobilephone];
        }];
    }
}

- (void)setValue:(NSString *)value {
    if (_editedValue.length > 0) {
        return;
    }
    _value = value;
    if ([Util isValidatePhone:value]) {
        _textField.text = [Util maskMobilePhone:value];
    }else {
        _textField.text = value;
    }
    _point.hidden = value.length > 0;
}

@end
