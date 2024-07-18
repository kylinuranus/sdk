//
//  SOSOnstarASTCell.m
//  Onstar
//
//  Created by Onstar on 2019/9/2.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSOnstarASTCell.h"
#import "AccountInfoUtil.h"

@implementation SOSOnstarASTCell
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self initUI];
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initUI];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}
-(void)initUI{
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    
    UIView * _containerView = [[UIView alloc] init];
    _containerView.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    _containerView.layer.cornerRadius = 4;
    _containerView.layer.shadowColor = [UIColor colorWithRed:101/255.0 green:112/255.0 blue:181/255.0 alpha:0.2].CGColor;
    _containerView.layer.shadowOffset = CGSizeMake(0,3);
    _containerView.layer.shadowOpacity = 1;
    _containerView.layer.shadowRadius = 8;
    [self.contentView addSubview:_containerView];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    _iconImg = [[UIImageView alloc] init];
    [_containerView addSubview:_iconImg];
    [_iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(16);
        make.top.mas_equalTo(17);
        make.width.height.mas_equalTo(22);
    }];
    
    
    _bottomBase = [[UIControl alloc] init];
    @weakify(self);
    [_bottomBase addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
        @strongify(self);
        [self readDetail];
    }];
    [_containerView addSubview:_bottomBase];
    [_bottomBase mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(34);
        make.leading.mas_equalTo(_containerView);
        make.trailing.mas_equalTo(_containerView);
        make.bottom.mas_equalTo(0);
    }];
    UILabel *sepL = [[UILabel alloc] init];
    [sepL setBackgroundColor:[UIColor colorWithHexString:@"F3F3F4"]];
    [_bottomBase addSubview:sepL];
    [sepL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_bottomBase);
        make.leading.mas_equalTo(_bottomBase);
        make.trailing.mas_equalTo(_bottomBase);
        make.height.mas_equalTo(1);
    }];
    //查看详情
    _goDetailL = [[UILabel alloc] init];
    [_goDetailL setText:@"查看详情"];
    [_goDetailL setTextColor:[UIColor colorWithHexString:@"6F717C"]];
    [_goDetailL setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 13]];
    [_bottomBase addSubview:_goDetailL];
    [_goDetailL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(sepL);
        make.leading.mas_equalTo(_bottomBase).mas_offset(26);
        make.trailing.mas_equalTo(_bottomBase).mas_offset(-38);
        make.bottom.mas_equalTo(_bottomBase);
    }];
    _arrow = [[UIImageView alloc] init];
    [_arrow setImage:[UIImage imageNamed:@"icon_arrow_right_warm_gray_idle"]];
    [_bottomBase addSubview:_arrow];
    [_arrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_bottomBase);
        make.trailing.mas_equalTo(_bottomBase).mas_offset(-16);
    }];
    //标题
    _titleL = [[UILabel alloc] init];
    [_titleL setTextColor:[UIColor colorWithHexString:@"#28292F"]];
    [_titleL setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:15]];
    [_containerView addSubview:_titleL];
    [_titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_iconImg);
        make.left.mas_equalTo(_iconImg.mas_right).mas_offset(8);
        make.right.mas_equalTo(_containerView);
    }];
    
    //时间
    _timeL = [[UILabel alloc] init];
    [_timeL setTextColor:[UIColor colorWithHexString:@"#A4A4A4"]];
    [_timeL setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 11]];
//    [_timeL setNumberOfLines:0];
    [_containerView addSubview:_timeL];
    [_timeL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_titleL);
        make.trailing.mas_equalTo(_containerView).mas_offset(-12);
    }];
    
    //描述
    _descL = [[UILabel alloc] init];
    [_descL setTextColor:[UIColor colorWithHexString:@"#4E5059"]];
    [_descL setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 14]];
    [_containerView addSubview:_descL];
    [_descL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(_titleL);
        make.trailing.mas_equalTo(_containerView).mas_offset(-12);
        make.top.mas_equalTo(_titleL.mas_bottom);
        make.bottom.mas_equalTo(_bottomBase.mas_top).mas_offset(-11);
    }];
    
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView).mas_offset(12);
        make.trailing.mas_equalTo(self.contentView).mas_offset(-12);
        make.top.mas_equalTo(self.contentView).mas_offset(5);
        make.bottom.mas_equalTo(self.contentView).mas_offset(-5);
    }];
    
}
-(void)updateView:(NotifyOrActModel*)model{
    self.model = model;
//        if ([dic valueForKey:@"type"]) {
    if ([model.thirdCategory isEqualToString:@"FAIL"]&&!model.status.boolValue) {
        [_iconImg setImage:[UIImage imageNamed:[NSString stringWithFormat:@"sos_messagecenter_icon_type_%@_FAIL_%d",model.secondCategory,model.status.boolValue]]];
        NSString * atStr = [NSString stringWithFormat:@"外呼三次未成功：%@",model.summary];
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc]initWithString:atStr];
        
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#C50000"] range:NSMakeRange(0, 7)];
        _descL.attributedText = attributeStr;

    }else{
        [_iconImg setImage:[UIImage imageNamed:[NSString stringWithFormat:@"sos_messagecenter_icon_type_%@%d",model.secondCategory,model.status.boolValue]]];
        [_descL setText:model.summary];

    }
//        }
    
    [_titleL setText:model.title];
    
    [_timeL setText:[self trimTimeStytle:model.sendDateTime]];
    
}
-(NSString *)trimTimeStytle:(NSString *)time{
    if (time.length >8) {
        NSString * cdate = [time substringWithRange:NSMakeRange(5, 5)];
        cdate = [cdate stringByReplacingOccurrencesOfString:@"-" withString:@"."];
        NSString * ctime = [time substringWithRange:NSMakeRange(time.length -8, 5)];
        time = [NSString stringWithFormat:@"%@ %@",cdate,ctime];
    }
    return time;
}
-(void)readDetail{
    if (self.model && self.model.content) {
//        NSLog(@"点击了查看详情=======");
//        [SOSDaapManager sendSysBanner:self.model.notificationId funcId:My_massage_detail];
        SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:self.model.content];
        [(UINavigationController *)[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:vc animated:YES];
        if (!self.model.status.boolValue) {
            [self setMsgReadState];
        }
        
    }
}
-(void)setMsgReadState{
    self.model.status = @"true";
    [_iconImg setImage:[UIImage imageNamed:[NSString stringWithFormat:@"sos_messagecenter_icon_type_%@%d",self.model.secondCategory,1]]];
    [AccountInfoUtil updateInfoReadStatusWithNotifyId:self.model.notificationId isDelete:NO];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
@end
