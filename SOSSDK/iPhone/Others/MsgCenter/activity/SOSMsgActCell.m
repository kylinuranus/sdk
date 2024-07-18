//
//  SOSMsgActCell.m
//  Onstar
//
//  Created by WQ on 2018/5/31.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSMsgActCell.h"
#import "UIImageView+WebCache.h"


@interface SOSMsgActCell ()

@property (weak, nonatomic) IBOutlet UIImageView *img_head;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bg_width;
@property (weak, nonatomic) IBOutlet UILabel *lb_text;
@property (weak, nonatomic) IBOutlet UIImageView *img_icon;
@property (weak, nonatomic) IBOutlet UIButton *btn_go;
@property (weak, nonatomic) IBOutlet UIImageView *img_line;

@property (weak, nonatomic) IBOutlet UILabel *lb_title01;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *text_bottom;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lb_title_width;
@property (weak, nonatomic) IBOutlet UILabel *lb_go;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lb_title_top;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lb_title_normal_top;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noImgTop;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hasImgTop;

@end

@implementation SOSMsgActCell
{
    NSString *content_url;
    NSString *notifyId;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor Gray246];
    self.img_line.backgroundColor = [UIColor Gray246];
    self.bg_width.constant = SCREEN_WIDTH-20;
}

- (void)fillData:(NotifyOrActModel*)m
{
    content_url = m.content;
    notifyId = m.notificationId;
//    NSURL *url = [NSURL URLWithString:m.pictureAdress];
//    [self.img_head sd_setImageWithURL:url];

    if (m.pictureAdress.isNotBlank) {
//        self.img_head.hidden = NO;
//        self.hasImgTop.priority = 999;
//        self.noImgTop.priority = 251;
        [self.img_head mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.height.mas_equalTo(128);
        }];
        NSURL *url = [NSURL URLWithString:m.pictureAdress.stringByTrim];
        [self.img_head sd_setImageWithURL:url];
    }else{
//        self.img_head.hidden = YES;
//        self.noImgTop.priority = 999;
//        self.hasImgTop.priority = 251;
        [self.img_head mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.height.mas_equalTo(0);
        }];
    }
    
    self.lb_title01.text = m.title;
    self.lb_text.text = m.summary;
    self.img_icon.hidden = [m.status isEqualToString:@"true"] ? YES : NO;  //true已读
    if (m.content.length < 1) {
        self.img_line.hidden = YES;
        self.btn_go.hidden = YES;
        self.lb_go.hidden = YES;
        
        [self.img_line mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        [self.btn_go mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        [self.lb_go mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];

    }else{
        self.img_line.hidden = NO;
        self.btn_go.hidden = NO;
        self.lb_go.hidden = NO;
        [self.img_line mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(1);
        }];
        [self.btn_go mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(30);
        }];
        [self.lb_go mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(10);
        }];
    }
}

- (IBAction)onPress:(UIButton *)sender {
    self.onPress(content_url,notifyId);
}

- (void)dealloc
{
    NSLog(@"-----dealloc-----");
}


@end
