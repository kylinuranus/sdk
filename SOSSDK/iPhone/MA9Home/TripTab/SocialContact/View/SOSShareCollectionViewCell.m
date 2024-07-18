//
//  SOSShareCollectionViewCell.m
//  Onstar
//
//  Created by Onstar on 2020/1/19.
//  Copyright © 2020 Shanghai Onstar. All rights reserved.
//

#import "SOSShareCollectionViewCell.h"
@interface SOSShareCollectionViewCell()
@property(nonatomic,strong)UIImageView * image;
@property(nonatomic,strong)UILabel * titleL;
@end
@implementation SOSShareCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}
-(void)initView{
//    self.backgroundColor = [UIColor redColor];
    _image = [[UIImageView alloc] init];
    [self addSubview:_image];
    [_image mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(34);
        make.centerX.mas_equalTo(self);
        make.centerY.mas_equalTo(self).mas_offset(-15);
    }];
    _titleL = [[UILabel alloc] init];
    [_titleL setTextColor:[UIColor colorWithHexString:@"4E5059"]];
    [_titleL setFont:[UIFont systemFontOfSize:12.0f]];
    [self addSubview:_titleL];
    [_titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(_image.mas_bottom).mas_offset(4);
    }];
}
-(void)setShareIconWithDic:(NSDictionary *)shareDic{
//    _shareDic = shareDic;
    [_image setImage:[UIImage imageNamed:[shareDic valueForKey:@"icon"]]];
    [_titleL setText:[shareDic valueForKey:@"title"]];
}
@end
