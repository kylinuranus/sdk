//
//  SOSCarSecretaryPromptView.m
//  Onstar
//
//  Created by TaoLiang on 2018/1/29.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSCarSecretaryPromptView.h"

@interface SOSCarSecretaryPromptView ()
@property (copy, nonatomic) NSString *prompt;
@property (weak, nonatomic) UILabel *promptLabel;
@end

@implementation SOSCarSecretaryPromptView

+ (instancetype)viewWithPrompt:(NSString *)prompt {
    SOSCarSecretaryPromptView *view = [SOSCarSecretaryPromptView new];
    view.prompt = prompt;
    return view;
}

- (void)show {
    self.alpha = 0;
    self.transform = CGAffineTransformMakeScale(2, 2);
    [UIView animateWithDuration:0.5 animations:^{
        self.transform = CGAffineTransformIdentity;
        self.alpha = 1;
    }];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:138/255.f green:214/255.f blue:149/255.f alpha:1];
        
        UILabel *promptLabel = [UILabel new];
        promptLabel.adjustsFontSizeToFitWidth = YES;
        promptLabel.font = [UIFont systemFontOfSize:15];
        promptLabel.textColor = [UIColor whiteColor];
        [self addSubview:promptLabel];
        [promptLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(@15);
            make.right.equalTo(@-15);
            make.centerY.equalTo(self);
            make.height.mas_equalTo(self);
        }];
        _promptLabel = promptLabel;
        
//        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        closeBtn.tintColor = [UIColor whiteColor];
//        [closeBtn setImage:[UIImage imageNamed:@"nav_icon_menu_close"] forState:UIControlStateNormal];
//        [closeBtn addTarget:self action:@selector(closeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:closeBtn];
//        [closeBtn mas_makeConstraints:^(MASConstraintMaker *make){
//            make.right.equalTo(@-10);
//            make.centerY.equalTo(self);
//            make.width.height.equalTo(@30);
//            make.left.equalTo(promptLabel.mas_right).offset(5);
//        }];

        UIButton *jumpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [jumpBtn addTarget:self action:@selector(jumpBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:jumpBtn];
        [jumpBtn mas_makeConstraints:^(MASConstraintMaker *make){
            make.edges.equalTo(promptLabel);
        }];

        
    }
    return self;
}

- (void)setPrompt:(NSString *)prompt {
    _prompt = prompt;
    _promptLabel.text = prompt;
}

- (void)closeBtnClicked:(UIButton *)sender {
    if (_closeBtnClicked) {
        _closeBtnClicked();
    }else {
        [self removeFromSuperview];
    }
}

- (void)jumpBtnClicked:(UIButton *)sender {
    if (_viewTapped) {
        _viewTapped();
    }
}


@end
