//
//  SOSMsgCenterCell.m
//  Onstar
//
//  Created by WQ on 2018/5/21.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSMsgCenterCell.h"

@interface SOSMsgCenterCell ()
@property (weak, nonatomic) IBOutlet UIImageView *img_icon;
@property (weak, nonatomic) IBOutlet UILabel *lb_title;
@property (weak, nonatomic) IBOutlet UILabel *lb_text;
@property (weak, nonatomic) IBOutlet UILabel *lb_date;
@property (strong, nonatomic)UIImageView *red;

@end


@implementation SOSMsgCenterCell

- (void)layoutSubviews
{
    [self modifiDeleteBtn];
}

- (void)modifiDeleteBtn{
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:NSClassFromString(@"UITableViewCellDeleteConfirmationView")]) {
            subView.backgroundColor=[UIColor blueColor];
            for (UIButton *btn in subView.subviews) {
                if ([btn isKindOfClass:[UIButton class]]) {
                    btn.backgroundColor=[UIColor blackColor];
                }
            }
        }
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    NSLog(@"awakeFromNib");
    self.lb_title.textColor = [UIColor colorWithHexString:@"000000"];
    self.lb_text.textColor = [UIColor colorWithHexString:@"646464"];
    self.lb_date.textColor = [UIColor colorWithHexString:@"C7CFD8"];

    // Initialization code
}

- (void)fillData:(MessageModel*)m
{
    NSString * iconStr;//STARAST
    iconStr = [NSString stringWithFormat:@"sos_messageCenter_%@",m.category];
    UIImage * iconImg;
    iconImg = [UIImage imageNamed:iconStr];
    if (iconImg) {
         self.img_icon.image = iconImg;
    }else{
        self.img_icon.image = [UIImage imageNamed:@"icon_message"];
    }
   
    self.lb_title.text = m.categoryZh;
    if ([m.category isEqualToString:@"FORUM"]) {
        NSDictionary * dic = [Util dictionaryWithJsonString:m.lastMsgTitle];
        if (dic) {
            NSAttributedString *attrStr = [[NSAttributedString alloc] initWithData:[[dic valueForKey:@"content"]dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:nil];
            self.lb_text.attributedText = attrStr;
        }
        
    }else{
        self.lb_text.text = m.lastMsgTitle;
    }
    
    if (m.lastMsgTime.length > 10) {
        NSString *s = [m.lastMsgTime substringToIndex:10];
        self.lb_date.text = s;
    }else
    {
        self.lb_date.text = m.lastMsgTime;
    }
    if (m.count > 0) {
        [self addRedPoint];
    }
}


- (void)addRedPoint
{
    [self.img_icon addSubview:self.red];
    [self.red mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_img_icon.mas_top);
        make.right.equalTo(_img_icon.mas_right);
        make.width.height.mas_equalTo(4);
    }];
}

- (UIImageView*)red
{
    if (!_red) {
        _red = [UIImageView new];
        _red.backgroundColor = [UIColor redColor];
        _red.layer.masksToBounds = YES;
        _red.layer.cornerRadius = 2;
    }
    return _red;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    NSLog(@"dealloc");
}


@end
