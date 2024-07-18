//
//  SOSInsuranceFloatView.h
//  Onstar
//
//  Created by Genie Sun on 2017/3/23.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SOSInsuranceFloatViewDelegate <NSObject>

- (void)tapTowebview;

@end

@interface SOSInsuranceFloatView : UIView

@property(nonatomic, strong) NSAttributedString *attributedText;
@property(nonatomic, strong) UIButton *arrowBtn;
@property (nonatomic,strong) UILabel *tipLb1;
@property (nonatomic,strong) UILabel *tipLb2;
@property(nonatomic, strong) UIView *tipLbBgView;
@property(nonatomic, strong) UIView *longview;
@property(nonatomic, strong) UIView *gestureReceiveView;
@property(nonatomic, strong) UITapGestureRecognizer *tap;
@property(nonatomic, assign) id <SOSInsuranceFloatViewDelegate> delegate;
@end
