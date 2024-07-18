//
//  SOSCarSecretarySectionHeaderView.m
//  Onstar
//
//  Created by TaoLiang on 2018/1/29.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSCarSecretarySectionHeaderView.h"

@interface SOSCarSecretarySectionHeaderView ()
@property (weak, nonatomic) UIView *containerView;

@property (weak, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *saveBtn;
@property (copy, nonatomic) SaveBtnAction action;
@end

@implementation SOSCarSecretarySectionHeaderView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [SOSUtil onstarLightGray];
        
        UIView *containerView = [UIView new];
        containerView.backgroundColor = [UIColor whiteColor];
        [self addSubview:containerView];
        [containerView mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.right.bottom.equalTo(self);
            make.height.equalTo(@34);
        }];
        _containerView = containerView;
        
        UIView *v_line = [UIView new];
        v_line.backgroundColor = [UIColor colorWithHexString:@"#6896ED"];
        [containerView addSubview:v_line];
        [v_line mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.and.centerY.equalTo(containerView);
            make.size.mas_equalTo(CGSizeMake(4, 16));
        }];

        UIView *h_line = [UIView new];
        h_line.backgroundColor = [UIColor colorWithHexString:@"C6C6C6"];
        [containerView addSubview:h_line];
        [h_line mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.right.bottom.equalTo(containerView);
            make.height.equalTo(@.5);
        }];


        UILabel *titleLabel = [UILabel new];
        titleLabel.font = [UIFont boldSystemFontOfSize:14];
        titleLabel.textColor = [UIColor colorWithHexString:@"#6896ED"];
        [containerView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.centerY.equalTo(containerView);
            make.left.mas_equalTo(12);
        }];

        _titleLabel = titleLabel;
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

//- (void)showSaveBtn:(SaveBtnAction)action {
//    if (!_saveBtn) {
//        _saveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//        [_saveBtn setTitle:@"保存" forState:UIControlStateNormal];
//        _saveBtn.titleLabel.font = [UIFont systemFontOfSize:13];
//        [_saveBtn addTarget:self action:@selector(saveBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//        _saveBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//        [_containerView addSubview:_saveBtn];
//        [_saveBtn mas_makeConstraints:^(MASConstraintMaker *make){
//            make.right.equalTo(@-15);
//            make.centerY.equalTo(_containerView);
//            make.height.equalTo(_containerView);
//            make.width.equalTo(@50);
//        }];
//
//    }
//    _action = action;
//}
//
//- (void)saveBtnClicked:(id)sender {
//    if (_action) {
//        _action();
//    }
//}

@end
