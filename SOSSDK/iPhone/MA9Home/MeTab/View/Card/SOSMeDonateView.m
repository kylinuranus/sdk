//
//  SOSMeDonateView.m
//  Onstar
//
//  Created by Onstar on 2018/12/21.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSMeDonateView.h"
#import "SOSDonateDataTool.h"
@interface SOSMeDonateView (){
    UIImageView * imageV;
    UILabel * titleLabel;
    UILabel * numberLabel;
    UILabel * subTitleLabel;
}@end
@implementation SOSMeDonateView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}
-(void)initView{
    titleLabel =[[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.font = [UIFont systemFontOfSize:14.0f];
    titleLabel.textColor=[UIColor colorWithHexString:@"#28292F"];
    [self addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(16.0f);
        make.top.mas_equalTo(18.0f);
//        make.height.mas_equalTo(20.0f);
    }];
    
    subTitleLabel=[[UILabel alloc] initWithFrame:CGRectZero];
    subTitleLabel.font = [UIFont systemFontOfSize:13.0f];
    subTitleLabel.textColor=[UIColor colorWithHexString:@"#6F717C"];
    [self addSubview:subTitleLabel];
    [subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(16.0f);
        make.top.mas_equalTo(titleLabel.mas_bottom).mas_equalTo(13.0f);
//        make.height.mas_equalTo(18.0f);
    }];
    
    imageV = [[UIImageView alloc] init];
    [self addSubview:imageV];
    [imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self).mas_offset(-30);
        make.centerY.equalTo(self);
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(70);
//        make.width.height.mas_equalTo(self.mas_height);
    }];
    
    [self configViewDefault];
}
-(UILabel *)getNumberLabel{
    if (!numberLabel) {
        numberLabel=[[UILabel alloc] initWithFrame:CGRectZero];
        numberLabel.font = [UIFont systemFontOfSize:13.0f];
        numberLabel.textColor=[UIColor colorWithHexString:@"#6896ED"];
        [self addSubview:numberLabel];
        [numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(titleLabel);
            make.left.mas_equalTo(titleLabel.mas_right).mas_offset(5.0f);
        }];
    }
    return numberLabel;
}
-(void)configViewDefault{
    titleLabel.text = @"加入我们，让世界充满爱！";
    if (numberLabel) {
        [self getNumberLabel].text = nil;
    }
    subTitleLabel.text = @"每一股潺流，终将汇成大海";
    imageV.image = [UIImage  imageNamed:@"me_donate_cell_imageV"];
}

-(void)configViewLoadDataSuccess:(NSString *)number{
    titleLabel.text = @"累计捐赠星能量";
    [self getNumberLabel].text = number;
    subTitleLabel.text = @"安吉星公益，让世界充满爱！";
    int userLevel = [SOSUtil getUserLevelWithDonationIntegral:number];
//    if (userLevel != 0) {
        imageV.image = [UIImage imageNamed:[NSString stringWithFormat:@"my_achievement_icon_star_medal_%@", @(userLevel)]];
//    }
}
- (void)refreshWithResponseData:(SOSDonateUserInfo *)responseData
                         status:(RemoteControlStatus)status{
    switch (status) {
        case RemoteControlStatus_OperateSuccess:
            [self configViewLoadDataSuccess:responseData.donationIntegral ? responseData.donationIntegral : @"0"];
            break;
        case RemoteControlStatus_InitSuccess:
            [self configViewDefault];

            break;
        case RemoteControlStatus_Void:
            [self configViewDefault];
            break;
        default:
            break;
    }
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
