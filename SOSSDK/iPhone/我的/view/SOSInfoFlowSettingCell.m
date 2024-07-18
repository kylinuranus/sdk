//
//  SOSInfoFlowSettingCell.m
//  Onstar
//
//  Created by TaoLiang on 2019/1/16.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSInfoFlowSettingCell.h"

@interface SOSInfoFlowSettingCell ()
@property (strong, nonatomic) UISwitch *switcher;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *subLabel;


@end

@implementation SOSInfoFlowSettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _switcher = [UISwitch new];
        [_switcher addTarget:self action:@selector(triggerd:)forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:_switcher];
        [_switcher mas_makeConstraints:^(MASConstraintMaker *make){
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(@-15);
        }];

        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#28292F"];
        [self.contentView addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(@16);
            make.top.equalTo(@17);
            make.right.equalTo(_switcher.mas_left).offset(-10);
            make.bottom.equalTo(@-17).priorityHigh();
        }];

        _subLabel = [UILabel new];
        [_subLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        _subLabel.font = [UIFont systemFontOfSize:13];
        _subLabel.textColor = [UIColor colorWithHexString:@"#828389"];
        [self.contentView addSubview:_subLabel];
        [_subLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.right.equalTo(_titleLabel);
            make.top.equalTo(_titleLabel.mas_bottom).offset(4);
            make.bottom.equalTo(@-17).priorityLow();
        }];

        

    }
    return self;
}

- (void)setSetting:(SOSInfoFlowSetting *)setting {
    _setting = setting;
    _titleLabel.text = _setting.switchTitle;
    _subLabel.text = _setting.switchContent;
    _switcher.on = [setting.status isEqualToString:@"ON"];
    
    [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make){
        make.bottom.equalTo(@-17).priority(_setting.switchContent.length > 0 ? 1 : 1000);
    }];
    [_subLabel mas_updateConstraints:^(MASConstraintMaker *make){
        make.bottom.equalTo(@-17).priority(_setting.switchContent.length > 0 ? 1000 : 1);
    }];

    
}

- (void)triggerd:(UISwitch *)switcher {
    _trigger ? _trigger(switcher.isOn) : nil;
}

@end
