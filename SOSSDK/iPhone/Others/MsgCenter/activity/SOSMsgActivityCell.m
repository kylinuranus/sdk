//
//  testCell.m
//  Onstar
//
//  Created by WQ on 2018/5/23.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSMsgActivityCell.h"

#define junjunGray [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1]
#define fontGray [UIColor colorWithRed:129/255.0 green:130/255.0 blue:135/255.0 alpha:1]
#define lineGray [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1]
#define fontGray153 [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1]
#define fontGray102 [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1]
#define fontGray246 [UIColor colorWithRed:246/255.0 green:243/255.0 blue:247/255.0 alpha:1]
#define fontGray52 [UIColor colorWithRed:52/255.0 green:52/255.0 blue:52/255.0 alpha:1]


@interface SOSMsgActivityCell ()

@property(nonatomic,strong)UIImageView *img_bg;
@property(nonatomic,strong)UIImageView *img_head;
@property(nonatomic,strong)UIImageView *img_icon;
@property(nonatomic,strong)UIImageView *img_line;
@property(nonatomic,strong)UILabel *lb_title;
@property(nonatomic,strong)UILabel *lb_text;
@property(nonatomic,strong)UIButton *btn_go;


@end

@implementation SOSMsgActivityCell


- (instancetype)initWithFrame:(CGRect)frame{
    
    self= [super initWithFrame: frame];
    
    if(self) {
        
        //self.backgroundColor= [UIColor blueColor];
        self.backgroundColor= fontGray246;

        self.img_bg = [UIImageView new];
        self.img_bg.backgroundColor = [UIColor cyanColor];
        self.img_bg.userInteractionEnabled = YES;
        [self.contentView addSubview:self.img_bg];
        
        self.img_head= [UIImageView new];
        self.img_head.backgroundColor= [UIColor yellowColor];
        [self.img_bg addSubview: self.img_head];

        self.lb_title= [UILabel new];
        self.lb_title.numberOfLines=0;
        self.lb_title.font = [UIFont systemFontOfSize:17.0];
        self.lb_title.textColor = [UIColor colorWithHexString:@"4A4A4A"];
        [self.img_bg addSubview: self.lb_title];

        self.img_icon= [UIImageView new];
        [self.img_bg addSubview: self.img_icon];

        self.lb_text= [UILabel new];
        self.lb_text.numberOfLines=0;
        self.lb_text.font = [UIFont systemFontOfSize:13.0];
        self.lb_text.textColor = [UIColor colorWithHexString:@"646464"];
        [self.img_bg addSubview: self.lb_text];

        self.img_line = [UIImageView new];
        self.img_line.backgroundColor = fontGray246;
        [self.img_bg addSubview:self.img_line];

        self.btn_go = [UIButton new];
        [self.btn_go setTitle:@"查看详情" forState:UIControlStateNormal];
        [self.btn_go setTitleColor:[UIColor colorWithHexString:@"4A4A4A"] forState:UIControlStateNormal];
        self.btn_go.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 200);
        [self.img_bg addSubview:self.btn_go];


        [self creatAutoLayout];
    }
    
    return self;
    
}

- (void)creatAutoLayout{
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker*make) {
        make.left.top.mas_equalTo(0);
        make.width.mas_equalTo(self.bounds.size.width);
        make.bottom.mas_equalTo(self.img_bg.mas_bottom).offset(12.0);
    }];
    
    [self.img_bg mas_makeConstraints:^(MASConstraintMaker*make) {
        make.top.equalTo(self.contentView);
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.bottom.mas_equalTo(self.btn_go.mas_bottom).offset(12.0);  //根据最后一个元素的位置确定背景图的底部位置
    }];
    
    [self.img_head mas_makeConstraints:^(MASConstraintMaker*make) {
        make.top.equalTo(self.contentView.mas_top).offset(1);
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.width.mas_equalTo(355);
        make.height.mas_equalTo(128);
    }];

    [self.lb_title mas_makeConstraints:^(MASConstraintMaker*make) {
        make.top.mas_equalTo(self.img_head.mas_bottom).offset(0);
        make.left.width.mas_equalTo(self.img_head);
    }];

    [self.lb_text mas_makeConstraints:^(MASConstraintMaker*make) {
        make.top.mas_equalTo(self.lb_title.mas_bottom).offset(0);
        make.left.width.mas_equalTo(self.lb_title);
    }];
    
    [self.img_line mas_makeConstraints:^(MASConstraintMaker*make) {
        make.top.mas_equalTo(self.lb_text.mas_bottom).offset(0);
        make.left.width.mas_equalTo(self.lb_title);
        make.height.mas_equalTo(1);
    }];
    
    [self.btn_go mas_makeConstraints:^(MASConstraintMaker*make) {
        make.top.mas_equalTo(self.img_line.mas_bottom).offset(0);
        make.left.width.mas_equalTo(self.img_line);
        make.height.mas_equalTo(30);
    }];

    @weakify(self)
    [[self.btn_go rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        self.onPress(self.tag);
    }];

}


- (void)fillData:(NotifyOrActModel*)m
{
    self.lb_title.text = m.title;
    self.lb_text.text = m.content;
}


- (UICollectionViewLayoutAttributes*)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes*)layoutAttributes {
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    CGSize size = [self.contentView systemLayoutSizeFittingSize: layoutAttributes.size];
    CGRect cellFrame = layoutAttributes.frame;
    cellFrame.size.height= size.height;
    layoutAttributes.frame= cellFrame;
    return layoutAttributes;
    
}
@end
