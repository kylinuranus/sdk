//
//  SOSNearBycell.m
//  Onstar
//
//  Created by WQ on 2018/7/5.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSNearBycell.h"

@interface SOSNearBycell (){
    UIImageView * arrow;
    UIImageView * phoneImg;
    UILabel *lb_name;
    UILabel *lb_address;
    UIButton *btn_phone;
    UILabel *lb_unit;
    UILabel *lb_distance;
}
@end

@implementation SOSNearBycell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initViews];
    }
    return self;
}
-(void)initViews{
    if (!arrow) {
        arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LBS_icon_arrow_right_passion_blue_idle"]];
        [self.contentView addSubview:arrow];
        [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(12);
            make.width.height.mas_equalTo(25);
            make.trailing.mas_equalTo(-7);
        }];
    }
    if (!lb_name) {
        lb_name = [[UILabel alloc] init];
        [lb_name setFont:[UIFont systemFontOfSize:16]];
        [lb_name setTextColor:[UIColor colorWithHexString:@"59708A"]];
        [self.contentView addSubview:lb_name];
        [lb_name mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(12);
            make.leading.mas_equalTo(22);
            make.height.mas_equalTo(23);
            make.trailing.mas_equalTo(30);
        }];
    }
    if (!lb_address) {
        lb_address = [[UILabel alloc] init];
        [lb_address setTextColor:[UIColor colorWithHexString:@"898994"]];
        [lb_address setFont:[UIFont systemFontOfSize:12]];
        [self.contentView addSubview:lb_address];
        [lb_address mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(lb_name.mas_bottom).mas_offset(6);
            make.height.mas_equalTo(23);
            make.trailing.mas_equalTo(30);
            make.leading.mas_equalTo(22);
        }];
    }
    if (!phoneImg) {
        phoneImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_phone"]];
        [self.contentView addSubview:phoneImg];
        [phoneImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(lb_address.mas_bottom).mas_offset(10);
            make.leading.mas_equalTo(22);
        }];
    }
    if (!lb_unit) {
        lb_unit = [[UILabel alloc] init];
        [lb_unit setFont:[UIFont systemFontOfSize:10]];
        [lb_unit setText:@"公里"];
        [self.contentView addSubview:lb_unit];
        [lb_unit mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(phoneImg);
            make.trailing.mas_equalTo(-30);
        }];
    }
    if (!lb_distance) {
           lb_distance = [[UILabel alloc] init];
           [lb_distance setFont:[UIFont systemFontOfSize:28]];
           [lb_distance setTextColor:[UIColor lightGrayColor]];
        [lb_distance setTextAlignment:NSTextAlignmentRight];
           [self.contentView addSubview:lb_distance];
           [lb_distance mas_makeConstraints:^(MASConstraintMaker *make) {
               make.centerY.mas_equalTo(phoneImg);
               make.height.mas_equalTo(23);
               make.width.mas_equalTo(70);
               make.right.mas_equalTo(lb_unit.mas_left);
           }];
       }
    if (!btn_phone) {
        btn_phone = [[UIButton alloc] init];
        [btn_phone addTarget:self action:@selector(btnOnPress:) forControlEvents:UIControlEventTouchUpInside];
        [btn_phone setTitleColor:[UIColor colorWithHexString:@"107FE0"] forState:0];
        [self.contentView addSubview:btn_phone];
        [btn_phone mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(phoneImg);
            make.height.mas_equalTo(40);
            make.left.mas_equalTo(phoneImg.mas_right).mas_offset(10);
//            make.right.mas_equalTo(lb_distance.mas_left);
        }];
    }
   
    
}
- (void)fillCellData:(NearByDealerModel*)m
{
    lb_name.text = m.dealerName;
    lb_address.text = m.address;
    NSString * telStr;
    if (m.telephone.isNotBlank && m.telephone.length > 5) {
           telStr = m.telephone;
       }else{
           telStr = @"暂无电话号码";
       }
    [btn_phone setTitle:telStr forState:0];
    lb_distance.text = [self modifyDistance:m.distance];
}

- (NSString*)modifyDistance:(NSString*)str
{
    if (str && str.isNotBlank) {
        CGFloat n = [str floatValue];
           NSString *s = [NSString stringWithFormat:@"%.1f",n];
           return s;
    }
    return @"";
   
}

- (void)btnOnPress:(UIButton *)sender {
    [SOSUtil callDearPhoneNumber:sender.titleLabel.text];
}



@end
