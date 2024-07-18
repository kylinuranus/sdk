//
//  SOSMeTableSectionHeaderView.m
//  Onstar
//
//  Created by Onstar on 2018/12/13.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSMeTableSectionHeaderView.h"
#import "UIImage+SOSSkin.h"

@implementation SOSMeTableSectionHeaderView
- (instancetype)initWithReuseIdentifier:(nullable NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self initView];
    }
    return self;
}
-(void)initView{
//    UIView * contentBase = [[UIView alloc] initWithFrame:CGRectZero];
//    contentBase.backgroundColor = [UIColor redColor];
//    [self addSubview:contentBase];
//    [contentBase mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self);
//    }];
    
    imgV = [[UIImageView alloc] init];
    [self addSubview:imgV];
    [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@22);
        make.height.equalTo(@22);
        make.leading.equalTo(@10);
        make.bottom.mas_equalTo(self).mas_offset(-4.0f);
    }];
    
    textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    textLabel.textColor = [SOSUtil onstarBlackColor];
    textLabel.font = [UIFont boldSystemFontOfSize:15.0f];
     [self addSubview:textLabel];
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(imgV.mas_trailing);
        make.centerY.equalTo(imgV.mas_centerY);
    }];
}
-(void)makeIcon:(NSString *)imgName titleText:(NSString *)title showAdditionRightButton:(BOOL)rightButton{
    imgV.image = [UIImage sosSDK_imageNamed:imgName];
    textLabel.text = title;
    if (rightButton) {
        [self addAdditionRightButton];
    }else{
        if (_rightBtn) {
            if (!_rightBtn.hidden) {
                _rightBtn.hidden = YES;
            }
        }
    }
}
-(void)addAdditionRightButton{
    if (!_rightBtn) {
        _rightBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [_rightBtn setTitle:@"更多" forState:0];
        [_rightBtn setImage:[UIImage imageNamed:@"right_Arrow"] forState:0];
        
        [_rightBtn setTitleColor:[UIColor colorWithHexString:@"#828389"] forState:0];
        [_rightBtn.titleLabel setFont:[UIFont fontWithName:@"PingFang-SC-Medium" size: 15]];
        CGSize titleSize = _rightBtn.titleLabel.bounds.size;
        CGSize imageSize = _rightBtn.imageView.bounds.size;
        CGFloat interval = 20.0f;
        
        _rightBtn.imageEdgeInsets = UIEdgeInsetsMake(0,titleSize.width + interval, 0, -(titleSize.width + interval));
        _rightBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -(imageSize.width + interval), 0, imageSize.width + interval);
        [self addSubview:_rightBtn];
        [_rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(-12.0f);
            make.centerY.mas_equalTo(imgV.mas_centerY);
        }];
    }
    
    _rightBtn.hidden = NO;
   
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
