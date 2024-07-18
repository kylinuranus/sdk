//
//  SOSCustomNotifyCell.m
//  Onstar
//
//  Created by Onstar on 2019/4/10.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSCustomNotifyCell.h"
@interface SOSCustomNotifyCell()
@property(nonatomic ,strong)UIImageView * iconImg;
@property(nonatomic ,strong)UILabel * titleL;
@property(nonatomic ,strong)UIControl * bottomBase ;
@property(nonatomic ,strong)UIImageView * arrow;
@property(nonatomic ,weak)NotifyOrActModel * model;

@end
@implementation SOSCustomNotifyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self initUI];
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initUI];
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
    //下部固定title
    _titleL = [[UILabel alloc] init];
    [_titleL setTextColor:[UIColor colorWithHexString:@"6F717C"]];
    [_titleL setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 13]];
    [_bottomBase addSubview:_titleL];
    [_titleL mas_makeConstraints:^(MASConstraintMaker *make) {
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
    //上部内容 . 后端返回结构叫content,无奈
     _contentL = [[UILabel alloc] init];
    [_contentL setTextColor:[UIColor colorWithHexString:@"#28292F"]];
    [_contentL setNumberOfLines:0];
    [_containerView addSubview:_contentL];
    [_contentL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_iconImg);
        make.left.mas_equalTo(_iconImg.mas_right).mas_offset(8);
        make.right.mas_equalTo(_containerView);
        make.bottom.mas_equalTo(_titleL.mas_top).mas_offset(-12);
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
    NSDictionary * dic = [Util dictionaryWithJsonString:model.summary];
    if (dic) {
        if ([dic valueForKey:@"type"]) {
            
            [_iconImg setImage:[UIImage imageNamed:[NSString stringWithFormat:@"forum_icon_type_%@%d",[dic valueForKey:@"type"],model.status.boolValue]]];
        }
        
        if ([dic valueForKey:@"content"]) {
            NSAttributedString *attrStr = [[NSAttributedString alloc] initWithData:[[dic valueForKey:@"content"]dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:nil];
            
            _contentL.attributedText = attrStr;
            [_contentL setFont:[UIFont fontWithName:@"PingFangSC-Regular" size: 15]];

        }
        if ([[dic valueForKey:@"title"] respondsToSelector:@selector(length)]) {
            [_titleL setText:([dic valueForKey:@"title"])];
        }else{
             [_titleL setText:nil];
        }
    }
        if (model.content) {
            //有跳转链接
            [_bottomBase mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(34);
            }];
            
            [_arrow mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(8);
                make.height.mas_equalTo(12);
            }];
        }else{
            [_bottomBase mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
            }];
            [_arrow mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.height.mas_equalTo(0);
            }];
        }
//    if (model.cont) {
//        <#statements#>
//    }
}
-(void)readDetail{
    if (self.model && self.model.content) {
        NSLog(@"点击了查看详情=======");
        [SOSDaapManager sendSysBanner:self.model.notificationId funcId:My_massage_detail];
        SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:self.model.content];
      
        [(UINavigationController *)[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:vc animated:YES];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
