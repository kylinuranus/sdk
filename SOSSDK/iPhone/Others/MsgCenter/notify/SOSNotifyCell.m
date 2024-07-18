//
//  SOSNotifyCell.m
//  Onstar
//
//  Created by WQ on 2018/5/25.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSNotifyCell.h"
#import "UIImageView+WebCache.h"

@interface SOSNotifyCell ()
@property (weak, nonatomic) IBOutlet UILabel *lb_title;
@property (weak, nonatomic) IBOutlet UIImageView *img_icon;
@property (weak, nonatomic) IBOutlet UILabel *lb_date;
@property (weak, nonatomic) IBOutlet UILabel *lb_text;
@property (weak, nonatomic) IBOutlet UIButton *btn_go;
@property (weak, nonatomic) IBOutlet UIImageView *img_line;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lb_text_bottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lb_title_width;
@property (weak, nonatomic) IBOutlet UILabel *lb_go;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lb_titleTop;
@property (weak, nonatomic) IBOutlet UIImageView *img_head;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lb_titleNoImgTop;

@end

@implementation SOSNotifyCell
{
    NSString *content_url;
    NSString *notifyId;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.lb_title.text = @"我是标题";
    self.lb_text.text = @"我是内容";
    self.lb_date.text = @"2018-06-01";
    self.lb_text.preferredMaxLayoutWidth = SCREEN_WIDTH-20;
    //self.backgroundColor = [UIColor colorWithHexString:@"e8ebef"];
    self.contentView.backgroundColor = [UIColor Gray246];
    self.img_line.backgroundColor = [UIColor Gray246];

}

- (void)fillData:(NotifyOrActModel *)m
{
    if (m.pictureAdress.length > 1) {
        self.img_head.hidden = NO;
        self.lb_titleTop.priority = 999;
        self.lb_titleNoImgTop.priority = 251;
        NSURL *url = [NSURL URLWithString:m.pictureAdress];
        [self.img_head sd_setImageWithURL:url];
    }else
    {
        self.img_head.hidden = YES;
        self.lb_titleNoImgTop.priority = 999;
        self.lb_titleTop.priority = 251;
    }
    
    content_url = m.content;
    notifyId = m.notificationId;
    self.lb_title.text = m.title;
    self.lb_title.textColor = [UIColor Gray102];
    if (m.title.length > 18) {
        self.lb_title_width.constant = 300.0;
        self.lb_title_width.priority = 999;
        [self layoutIfNeeded];
    }
    self.lb_text.text = m.summary;
    self.lb_text.textColor = [UIColor Gray153];
    self.lb_date.text = m.sendDate;
    self.lb_date.textColor = [UIColor Gray129];
    self.img_icon.hidden = [m.status isEqualToString:@"true"] ? YES : NO;   //true已读
    self.lb_text_bottom.priority = 250;
    if (m.content.length < 1) {
        self.btn_go.hidden = YES;
        self.img_line.hidden = YES;
        self.lb_go.hidden = YES;
        self.lb_text_bottom.priority = 999; //隐藏按钮时打开
        [self layoutIfNeeded];
    }else
    {
        self.lb_text_bottom.priority = 250;
        self.btn_go.hidden = NO;
        self.img_line.hidden = NO;
        self.lb_go.hidden = NO;
    }
}


- (IBAction)btnOnPress:(UIButton *)sender {
    self.onPress(content_url,notifyId);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
